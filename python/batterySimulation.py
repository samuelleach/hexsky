#! /usr/bin/env python
# batterySimulation.py
# Alexander Smith
# August 25, 2010
#
# This code calculates the estimated battery charge during a simulated flight.  It uses the
# data in a simulated pointing file to estimate the power production by the solar modules.
# Based on the estimated power consumption, it then estimates the power drawn from/delivered
# to the battery and estimates the charge remaining in the battery.
#
# USAGE: ./batterySimulation.py [dataVx.dat] [outVx.dat] [T]
# where the order of the options is important.
# See batteryScript for an example input.
#
# OUTPUT: produces plots in ../plots/ and writes to the outVx.dat file.

from numpy import *
#SL import matplotlib.pyplot as plt
import pdb
import sys
import os
import math #SL

# MAIN
def main():
    # define_assumptions
    floatT,cc_ineff,numModule,Pconsume,mountAngle,consume_cont,battVolt, \
           setupTime,albedo, cosIcrit \
           = define_assumptions()

    # open_files
    dataFile,dataHandle,outFile,outHandle,simDate = open_files(floatT)

    # find_num_lines
    num_lines = find_num_lines(dataFile)

    # find_vert_lines
    if len(sys.argv) >= 5:
        vertLines,commandNames = find_vert_lines()

    # specify_batteries
    totalBattEnergy = specify_batteries(battVolt)

    # create_variables
    JD,JD_0,AZ,EL,sunAZ,sunEL,lon,lat,Pproduce,battEnergy,powerDiff,timeRemaining, \
                              timeCharge,currentLine,full, azangSep, elangSep, cosangSep \
           = create_variables(totalBattEnergy,num_lines)

    # add_consumption_contingency
    Pconsume = add_consumption_contingency(Pconsume,consume_cont,currentLine)

    # ground_setup
    battEnergy,JD = ground_setup(setupTime,battEnergy,Pconsume,JD)

    # loop through data file
    for line in dataHandle:
        # check not a comment
        if line[0] == '#':   
            print line
        else:
            # read_data
            JD,JD_0,AZ,EL,sunAZ,sunEL,lon,lat = read_data(line,JD,JD_0,AZ,EL,sunAZ,
                            sunEL,lon,lat,currentLine)
            # calculate_power_production
            Pproduce = calculate_power_production(AZ,EL,sunAZ,sunEL,floatT,
                  numModule,mountAngle,Pproduce,albedo,currentLine, azangSep, elangSep, cosangSep)
            # add_production_deration
            Pproduce = add_production_deration(Pproduce,cc_ineff,currentLine)
            # update_battery_energy
            battEnergy,timeRemaining,timeCharge,GAMEOVER,full = update_battery_energy(JD,battEnergy,
                        totalBattEnergy,Pproduce,Pconsume,timeRemaining,timeCharge,currentLine,full)
            # write_to_file
            write_to_file(outHandle,JD,AZ,EL,sunAZ,sunEL,lon,lat,
                          battEnergy,totalBattEnergy,Pproduce,Pconsume,currentLine)
            if GAMEOVER:
                # game_over
                game_over(JD,battEnergy,Pproduce,Pconsume,currentLine)
                break

            currentLine = currentLine + 1

    # set JD of first vertical line to zero
    if len(sys.argv) >= 5:
        vertLines = vertLines - JD_0

    # plot_data
    if len(sys.argv) >= 5:
    	plot_data(JD,AZ, sunAZ, battEnergy,totalBattEnergy,Pproduce,Pconsume,timeRemaining, \
		timeCharge,simDate,floatT,vertLines, consume_cont, numModule, azangSep, elangSep, \
		cosangSep, albedo, cosIcrit)

    dataHandle.close()
    outHandle.close()
    #os.system('open ../plots/*'+simDate+'_'+str(floatT)+'.png')



########## FUNCTIONS ########## FUNCTIONS ########## FUNCTIONS ##########            


# DEFINE_ASSUMPTIONS
def define_assumptions():
    if len(sys.argv) >= 4:
        floatT = int(sys.argv[3])
        print "Using module temperature = ",sys.argv[3]
    else:
        floatT = 100
        print "Using module temperature = 105"
    cc_ineff = 0.95
#    numModule = array([15,18])
#    numModule = array([12,15])
    numModule = array([15,15]) # With switchable panel : BRK to SL.
    if numModule[0] == [12]:
	cosIcrit = [.71, .69]
    if numModule[0] == [15]:
	cosIcrit = [.57, .58]
    Pconsume = array([646.4,789.5]) #value includes cooling system pump BRK, 20 W x 2
#    Pconsume = array([606.4,789.5]) values pre 11/2010 BRK
    mountAngle = 23.5
    consume_cont = 1.1
    battVolt = array([29.0, 28.5, 27.7, 27.2, 26.75, 26.5, 26.4, 26.2, 25.8, 25.6, 25.5,
                 25.3, 25.2, 25.1, 25.0, 24.9, 24.7, 24.6, 24.0, 21.8])
#    setupTime = 1.5
    setupTime = 2
#BRK
    albedo = .00
#BRK
#AS    albedo = 0.53/pi*.4 # see batt capacity memo for details of albedo; = 0.0675

    return floatT, cc_ineff, numModule, Pconsume, mountAngle, consume_cont, \
           battVolt, setupTime, albedo, cosIcrit


# OPEN_FILES
def open_files(floatT):
    # open line used to delineate between scanning modes
    
    # specify input and output files
    if len(sys.argv) >= 3:
        dataFile = sys.argv[1]
        outFile = sys.argv[2]
        print 'Input files:\n\t',dataFile, '\n\t',outFile
    else:
        dataFile = '../data/test_Dec16.dat'
        outFile = '../data/out_Dec16.dat'
        print 'Using default input files:\n\t',dataFile, '\n\t',outFile
    simDate = dataFile[5:14]
    # open files
    outHandle = open(outFile,'w')
    dataHandle = open(dataFile,'r+')
    # write header
    outHandle.write("# ACS_%Remain BOLO_%Remain ACS_Pproduce-Pconsume BOLO_Pproduce-Pconsume\n")
    #print '\n\n# Time (Hr)\tACS(%)\t\tBOLO(%)\t\tACS(time)\tBOLO(time)'
    
    return dataFile,dataHandle,outFile,outHandle,simDate


# FIND_NUM_LINES
def find_num_lines(dataFile):
    #find number of lines in file
    file = open(dataFile,'r+')
    num_lines = len(file.readlines()) - 1
    file.close()

    return num_lines

# FIND_VERT_LINES
def find_vert_lines():
    vertLines = array([])
    commandNames = array([])
    vertLineFile = sys.argv[4]
    vertLineHandle = open(vertLineFile,'r+')
    previousCommand = "noPreviousCommand"
    for line in vertLineHandle:
        if line[0] == '#':   
            print line
        else:
            line = line.rstrip('\n')
            if line.split()[2] != previousCommand:
                vertLines = append(vertLines,float(line.split()[0]))
                previousCommand = line.split()[2]
                commandNames = append(commandNames,line.split()[2])
    return vertLines,commandNames


# SPECIFY_BATTERIES
def specify_batteries(battVolt):
    # Find energy contrained in the P60 and P38 batteries
    # P60
    totalEnergy104 = 104 * mean(battVolt) * 3600
    # P38
    totalEnergy20 = 20 * mean(battVolt) * 3600
    # ACS = 1 x P60 battery
    # BOLO = 1 x P60 battery  +  2 x P38 batteries
#    totalBattEnergy = [totalEnergy104,totalEnergy104+2*totalEnergy20] #joules
#    totalBattEnergy = [totalEnergy104+totalEnergy20,2*totalEnergy104] #joules
    totalBattEnergy = [totalEnergy104+2*totalEnergy20, 2*totalEnergy104] #joules

#    print mean(battVolt)

    return totalBattEnergy
    

# CREATE VARIABLES
def create_variables(totalBattEnergy,num_lines):
    # variables from input file
    JD = zeros(num_lines+2) # +2 accounts for ground setup times
    AZ = zeros(num_lines+2)
    EL = zeros(num_lines+2)
    sunAZ = zeros(num_lines+2)
    sunEL = zeros(num_lines+2)
    lon = zeros(num_lines+2)
    lat = zeros(num_lines+2)
    azangSep = zeros(num_lines+2)
    elangSep = zeros(num_lines+2)
    cosangSep = zeros(num_lines+2)
    # power production
    Pproduce = zeros((2,num_lines+2))
    # energy remaining in the batteries, initialized to a full battery
    battEnergy = ones((2,num_lines+2))
    battEnergy[0,:] = battEnergy[0,:] * totalBattEnergy[0] #ACS
    battEnergy[1,:] = battEnergy[1,:] * totalBattEnergy[1] #BOLO
    # definition: powerDiff = Pproduce - Pconsume
    powerDiff = zeros((2,num_lines+2))
    timeRemaining = zeros((2,num_lines+2))
    timeCharge = zeros((2,num_lines+2))
    currentLine = 2 #lines 0 and 1 reserved for t0 and ground setup
    JD_0 = 0
    full = [False,False]

    return JD,JD_0,AZ,EL,sunAZ,sunEL,lon,lat,Pproduce,battEnergy,powerDiff,timeRemaining,\
		timeCharge,currentLine,full,azangSep, elangSep, cosangSep


# ADD_CONSUMPTION_CONTINGENCY
def add_consumption_contingency(Pconsume,consume_cont,currentLine):

    Pconsume = Pconsume * consume_cont

    return Pconsume


# GROUND_SETUP
def ground_setup(setupTime,battEnergy,Pconsume,JD):
    battEnergy[0,1] = battEnergy[0,1] - setupTime*3600*Pconsume[0] #ACS  hr*(sec/hr)*P in W = E in J
    battEnergy[1,1] = battEnergy[1,1] - setupTime*3600*Pconsume[1] #BOLO

    JD[0] = 0
    JD[1] = setupTime/24.
    
    return battEnergy,JD


# READ_DATA
def read_data(line,JD,JD_0,AZ,EL,sunAZ,sunEL,lon,lat,currentLine):
    line = line.rstrip('\n')
    line = [float(x) for x in line.split()]
    if currentLine == 2: #first line of file
        JD_0 = line[0] - JD[1] #start JD - setupTime
        print "JD = ", line[0]
    JD[currentLine] = line[0] - JD_0
    AZ[currentLine] = (line[1])*pi/180. # modules mounted towards sun
#    AZ[currentLine] = (line[1])*pi/180. - pi # modules mounted towards sun
#    AZ[currentLine] = mod((line[1])*pi/180. - pi, 2.*pi) # modules mounted towards sun
    EL[currentLine] = line[2]*pi/180.
    sunAZ[currentLine] = line[3]*pi/180.
    sunEL[currentLine] = line[4]*pi/180.
    lon[currentLine] = line[5]
    lat[currentLine] = line[6]                  


    return JD,JD_0,AZ,EL,sunAZ,sunEL,lon,lat


# CALCULATE_POWER_PRODUCTION
def calculate_power_production(AZ,EL,sunAZ,sunEL,floatT,numModule,
                               mountAngle,Pproduce,albedo,currentLine, azangSep, elangSep, cosangSep):
    # pull vars out of array
    az = AZ[currentLine] 
#    el = (mountAngle+12.5)*pi/180.
    el = (mountAngle)*pi/180.
    sunaz = sunAZ[currentLine]
    sunel = sunEL[currentLine]
    # calculate maximum solar array output at current temp;  this should be = ~ 76 W
    floatInsol = 1366
    groundInsol = 1000
    standardT = 25
    singleModP = 2.67
    powerDeration = -0.004
    numCellsInModule = 30

# ADD attenuation due to the atmosphere
#BRK  JD[542] corresponds to 3 hours after launch (JD[542] = 0.2083 = 5 hr)

    if currentLine < 542:
	flightModPower = numCellsInModule * singleModP * (1 + powerDeration \
                            * (floatT-standardT)) * floatInsol/groundInsol
#                            * (floatT-standardT)) * 1000*e**(currentLine/1742.0)/groundInsol
    else:
	flightModPower = numCellsInModule * singleModP * (1 + powerDeration \
                            * (floatT-standardT)) * floatInsol/groundInsol

    # calculate angular separation of modules and sun
#    angSep = arctan(sqrt(cos(sunel)**2*sin(sunaz-az)**2 + \  (This equation not correct)
    #                            (cos(el)*sin(sunel)-sin(el)*cos(sunel) \
     #                           *cos(sunaz-az))**2)/(sin(el)*sin(sunel) + \
      #                          cos(el)*cos(sunel)*cos(sunaz-az)))
#SL    azangSep = abs(az-sunaz) - pi # test spinning

    #SL
    az_deg        = az    * 180./pi  
    sunaz_deg     = sunaz * 180./pi
    delta360      = ( az_deg - (sunaz_deg + 180. ) ) % 360.
    azangSep_deg  = delta360 - (int(math.floor(delta360))/180)*360.
    azangSep[currentLine]      = azangSep_deg * pi / 180.
    #SL

    #BRK
    elangSep[currentLine] = (el - sunel)
    #BRK
#    if  abs(azangSep) > pi/2:  (This equation doesn't apply now)
#        azangSep = pi/2   

#    elangSep = el - sunel    (This equation is wrong)

    # calculate total power production
#    Pproduce[:,currentLine] = flightModPower * numModule * (cos(azangSep) + albedo)
#    Pproduce[:,currentLine] = flightModPower * numModule * (cos(azangSep)*cos(elangSep) + albedo)

#SL Correct angular separation calculations and conditions!
    cosAngleOfIncidence = sin(sunel)*cos(pi/2.-el) + cos(sunaz-(az+pi))*cos(sunel)*sin(pi/2.-el)
    if cosAngleOfIncidence < 0:
        cosAngleOfIncidence = 0.
#BRK
    Pproduce[:,currentLine] = flightModPower * (1+albedo) * numModule * (cosAngleOfIncidence)
#BRK
#    Pproduce[:,currentLine] = flightModPower * numModule * (cosAngleOfIncidence + albedo)
    cosangSep[currentLine] = cosAngleOfIncidence

    return Pproduce

# ADD_PRODUCTION_DERATION
def add_production_deration(Pproduce,cc_ineff,currentLine):
    Pproduce[:,currentLine] = Pproduce[:,currentLine] * cc_ineff

    return Pproduce

# UPDATE_BATTERY_ENERGY
def update_battery_energy(JD,battEnergy,totalBattEnergy,Pproduce,Pconsume,timeRemaining,timeCharge,currentLine,full):
    deltaJD = (JD[currentLine] - JD[currentLine-1])*3600*24 #seconds

    # update battery energy
    battEnergy[:,currentLine] = battEnergy[:,currentLine-1] + deltaJD * \
                              (Pproduce[:,currentLine] - Pconsume)
    for i in arange(2):
        if currentLine > 11:
            meanSlope = mean((battEnergy[i,currentLine-9:currentLine] - \
                      battEnergy[i,currentLine-10:currentLine-1]) \
                     / (JD[currentLine-9:currentLine]-JD[currentLine-10:currentLine-1]))
        else:
            meanSlope = (battEnergy[i,currentLine] - battEnergy[i,currentLine-1]) \
                     / (JD[currentLine]-JD[currentLine-1])
        if battEnergy[i,currentLine]>battEnergy[i,currentLine-1]:
            timeRemaining[i,currentLine] = battEnergy[i,currentLine] / meanSlope
            timeCharge[:,currentLine] = 0 #timeCharge[:,currentLine-1]
        elif battEnergy[i,currentLine]==battEnergy[i,currentLine-1]:
            timeRemaining[i,currentLine] = battEnergy[i,currentLine]/Pconsume[i]
            timeCharge[:,currentLine]=0
        else:
            timeRemaining[i,currentLine] = 0 #timeRemaining[i,currentLine-1]
            timeCharge[i,currentLine] = -battEnergy[i,currentLine] / meanSlope
    sysName = ["ACS","BOLO"]
    for sys in [0,1]:
        # check if battery is full
        if battEnergy[sys,currentLine] > totalBattEnergy[sys]:
            battEnergy[sys,currentLine] = totalBattEnergy[sys]
            if (not full[sys]):
                print sysName[sys], " battery full at ",JD[currentLine]*24," hours"
                full[sys] = True
    # check if battery is empty
    if any(battEnergy <= 0):
        GAMEOVER = True
    else:
        GAMEOVER = False

    return battEnergy,timeRemaining,timeCharge,GAMEOVER,full
        

def write_to_file(outHandle,JD,AZ,EL,sunAZ,sunEL,lon,lat,battEnergy,totalBattEnergy,Pproduce,
                  Pconsume,currentLine):
    """
    outHandle.write('{0:12.8f} {1:12.8f} {2:12.8f} {3:12.8f} {4:12.8f} {5:10.3f} {6:10.3f} {7:12.8f} {8:12.8f} {9:15.8f} {10:15.8f} \n'
                .format(JD[currentLine], AZ[currentLine], EL[currentLine],
                        sunAZ[currentLine],sunEL[currentLine], lon[currentLine],
                        lat[currentLine],battEnergy[0,currentLine]/totalBattEnergy[0],
                        battEnergy[1,currentLine]/totalBattEnergy[1],
                        Pproduce[0,currentLine]-Pconsume[0],
                        Pproduce[1,currentLine]-Pconsume[1]))
    """
#SL    outHandle.write('%12.8f %12.8f %12.8f %12.8f %12.8f %10.3f %10.3f %12.8f %12.8f %15.8f %15.8f \n'
#                % (JD[currentLine], AZ[currentLine], EL[currentLine],
#                        sunAZ[currentLine],sunEL[currentLine], lon[currentLine],
#                        lat[currentLine],battEnergy[0,currentLine]/totalBattEnergy[0],
#                        battEnergy[1,currentLine]/totalBattEnergy[1],
#                        Pproduce[0,currentLine]-Pconsume[0],
#SL                        Pproduce[1,currentLine]-Pconsume[1])) # python 2.5.5 compliant

    outHandle.write('%12.8f %12.8f %15.8f %15.8f \n'
                    % (battEnergy[0,currentLine]/totalBattEnergy[0],
                       battEnergy[1,currentLine]/totalBattEnergy[1],
                       Pproduce[0,currentLine]-Pconsume[0],
                       Pproduce[1,currentLine]-Pconsume[1])) # python 2.5.5 compliant


# GAME_OVER
def game_over(JD,battEnergy,Pproduce,Pconsume,currentLine):
    battEnergy[:,currentLine::] = 0
    #Pproduce[0,currentLine] = Pconsume[0] #set last val of Pp-Pc to zero
    #Pproduce[1,currentLine] = Pconsume[1]
    JD[currentLine::] = JD[currentLine]
#    print "\n*****GAME OVER*****\n\nElapsedTime = {0:5.2f} days\n".format(JD[currentLine])
    
    return battEnergy


# PLOT_DATA
def plot_data(JD,AZ, sunAZ, battEnergy,totalBattEnergy,Pproduce,Pconsume,timeRemaining, \
		timeCharge,simDate,floatT,vertLines, consume_cont, numModule, azangSep, \
		elangSep, cosangSep, albedo, cosIcrit):
    # battery percentage
    plt.clf()
    plt.figure(1)
    if totalBattEnergy == [9654840.0, 13368240.0]: 
	battconfigacs = "104"
  	battconfigbolo = "144"
    if totalBattEnergy ==  [11511540.0, 19309680.0]:
	battconfigacs = "124"
  	battconfigbolo = "208"
    if totalBattEnergy == [13368240.0, 19309680.0]: 
	battconfigacs = "144"
  	battconfigbolo = "208"
    plt.plot(JD,battEnergy[0,:]/totalBattEnergy[0]*100, linestyle='solid', label = "ACS:  "+\
		str(numModule[0])+" modules, "+battconfigacs+" Ahr")
    plt.plot(JD,battEnergy[1,:]/totalBattEnergy[1]*100, linestyle='dashed', label = "BOLO:  "+\
		str(numModule[1])+" modules, "+battconfigbolo+" Ahr")
    plt.ylabel('Battery Energy [%]')
    plt.xlabel('Time [days]')
    plt.title(simDate+", "+str(consume_cont)+" contingency on power needed, T = "+str(sys.argv[3])+" C")
    plt.ylim((0,120))
    for vline in vertLines:
        plt.axvline(x=vline,color='k',linestyle=":")
    plt.legend(loc = 0)
#    plt.savefig("plots/batteryEnergy_1hrground"+str(int(consume_cont*100))+"pct"+str(sys.argv[3])+"C"+\
#		"_"+simDate+"_"+str(numModule[0])+"_"+str(numModule[1])+"_"+battconfigacs+"_" \
#		+battconfigbolo+"_alb0"+".png")

    # power production - power consumption
    plt.figure(2)
    plt.plot(JD,Pproduce[0,:]-Pconsume[0], linestyle='solid', label = "ACS")
    plt.plot(JD,Pproduce[1,:]-Pconsume[1], linestyle='dashed', label = "BOLO")
    plt.ylabel('Power production - Power consumption) [W]')
    plt.xlabel('Time [days]')
    plt.title(simDate)
    for vline in vertLines:
        plt.axvline(x=vline,color='k',linestyle="--")
    plt.legend(loc = 0)
#    plt.savefig("../plotsbritt/powerDiff_"+str(floatT)+'_'+simDate+"_"+battconfig)

    # deltaEnergy
    plt.figure(3)
    plt.plot(JD,timeRemaining[0,:]*24, linestyle='solid', label = "ACS_time_remaining")
    plt.plot(JD,timeRemaining[1,:]*24, linestyle='dashed', label = "BOLO_time_remaining")
    plt.plot(JD,timeCharge[0,:]*24, linestyle='solid', label = "ACS_time_to_charge")
    plt.plot(JD,timeCharge[1,:]*24, linestyle='dashed', label = "BOLO_time_to_charge")
    plt.ylabel('Time remaining or charge time of batteries [hrs]')
    plt.xlabel('Time [days]')
    plt.title(simDate)
    for vline in vertLines:
        plt.axvline(x=vline,color='k',linestyle="--")
    plt.ylim((0,50))
    plt.legend(loc = 0)
#    plt.savefig("../plotsbritt/timeRemaining_"+str(floatT)+'_'+simDate+"_"+battconfig)

    # Gondola Azimuth and Sun Azimuth
    plt.figure(4)
    plt.plot(JD,AZ*180/pi, linestyle='solid',  label = "Gondola AZ")
    plt.plot(JD,sunAZ*180/pi, linestyle='solid',linewidth = 2, label = "SUN AZ")
    plt.ylabel('Azimuth (deg)')
    plt.xlabel('Time [days]')
    plt.title(simDate)
    for vline in vertLines:
        plt.axvline(x=vline,color='k',linestyle="--")
    plt.legend(loc = 0)
#    plt.savefig("plots/az_"+str(floatT)+'_'+simDate)

    # azangSep 
    plt.figure(5)
    plt.plot(JD, azangSep*180/pi, linestyle='solid')
    plt.ylabel("Azimuth Angular separation between panels and sun (deg)")
    plt.xlabel('Time (days)')
    plt.title(simDate)
    for vline in vertLines:
        plt.axvline(x=vline,color='k',linestyle="--")
#    plt.savefig("plots/azangsep_"+simDate+".png")

    # elangSep 
    plt.figure(6)
    plt.plot(JD, elangSep*180/pi, linestyle='solid')
    plt.ylabel("Elevation Angular separation between panels and sun (deg)")
    plt.xlabel('Time (days)')
    plt.title(simDate)
    for vline in vertLines:
        plt.axvline(x=vline,color='k',linestyle="--")
#    plt.savefig("plots/elangsep_"+simDate+".png")

    # cosangSep 
    plt.figure(7)
    plt.plot(JD, cosangSep, 'bo', markersize = 2, markeredgewidth = 0)
    plt.ylabel("Cosine of angular separation between panels and sun")
    plt.xlabel('Time (days)')
    plt.title(simDate)
    for vline in vertLines:
        plt.axvline(x=vline,color='k',linestyle="--")
#    plt.savefig("plots/cosangsep_"+simDate+".png")

    # ratio of pproduced/pconsumed 
    plt.figure(8)
    plt.plot(JD, Pproduce[0]/Pconsume[0], 'bo', markersize = 2, markeredgewidth = 0, label="ACS")
    plt.plot(JD, Pproduce[1]/Pconsume[1], 'go', markersize = 2, markeredgewidth = 0, label="BOLO")
    plt.plot(JD, zeros(len(JD))+1, 'r-')
    plt.legend()
    plt.ylabel("Pproduce/Pconsume")
    plt.xlabel('Time (days)')
    plt.title(simDate)
    for vline in vertLines:
        plt.axvline(x=vline,color='k',linestyle="--")
#    plt.savefig("plots/prod_over_consume_"+simDate+".png")

    # cosIcrit 
    plt.figure(9)
    plt.plot(JD, cosangSep/cosIcrit[0], 'bo', markersize = 2, markeredgewidth = 0, label="ACS_"+\
	str(numModule[0])+" modules")
    plt.plot(JD, cosangSep/cosIcrit[1], 'go', markersize = 2, markeredgewidth = 0, label="BOLO_"+\
	str(numModule[1])+" modules")
    plt.plot(JD, zeros(len(JD))+1, 'r-')
    plt.legend(loc = 4)
    plt.ylabel("cos(angular separation)/cos(I critical)")
    plt.xlabel('Time (days)')
    plt.title(simDate)
    for vline in vertLines:
        plt.axvline(x=vline,color='k',linestyle="--")
    plt.savefig("plots/cosIcrit_"+simDate+"_"+str(numModule[0])+str(numModule[1])+".png")

main()
