;+
; NAME:
;  SETUNION
;
; PURPOSE:
;
;   This function is used to find the union between two sets of integers.
;
; AUTHOR:
;
;   FANNING SOFTWARE CONSULTING
;   David Fanning, Ph.D.
;   1645 Sheely Drive
;   Fort Collins, CO 80526 USA
;   Phone: 970-221-0438
;   E-mail: davidf@dfanning.com
;   Coyote's Guide to IDL Programming: http://www.dfanning.com/
;
; CATEGORY:
;
;   Utilities
;
; CALLING SEQUENCE:
;
;   union = SetUnion(set_a, set_b)
;
; RETURN VALUE:
;
;   union:  A vector of values that are found in the combined integer sets.
;
; ARGUMENTS:
;
;   set_a:         A vector of integers.
;   
;   set_b:         A vector of integers.
;
; KEYWORDRS:
;
;  NORESULT:       Set this keyword to a value that will be returned from the function
;                  if no intersection between the two sets of numbers is found. By default, -1.
;
;  SUCCESS:        An output keyword that is set to 1 if a union was found, and to 0 otherwise.
;
; EXAMPLE:
;
;  IDL> set_a = [1,2,3,4,5]
;  IDL> set_b = [4,5,6,7,8,9,10,11]
;  IDL> Print, SetUnion(set_a, set_b)
;          1  2  3  4  5  6  7  8  9  10  11
;
;  See http://www.dfanning.com/tips/set_operations.html for other types of set operations.
;  
; MODIFICATION HISTORY:
;
;  Written by: David W. Fanning, November 25, 2009, from code originally supplied to the IDL
;     newsgroup by Research Systems software engineers.
;-
;******************************************************************************************;
;  Copyright (c) 2009, by Fanning Software Consulting, Inc.                                ;
;  All rights reserved.                                                                    ;
;                                                                                          ;
;  Redistribution and use in source and binary forms, with or without                      ;
;  modification, are permitted provided that the following conditions are met:             ;
;                                                                                          ;
;      * Redistributions of source code must retain the above copyright                    ;
;        notice, this list of conditions and the following disclaimer.                     ;
;      * Redistributions in binary form must reproduce the above copyright                 ;
;        notice, this list of conditions and the following disclaimer in the               ;
;        documentation and/or other materials provided with the distribution.              ;
;      * Neither the name of Fanning Software Consulting, Inc. nor the names of its        ;
;        contributors may be used to endorse or promote products derived from this         ;
;        software without specific prior written permission.                               ;
;                                                                                          ;
;  THIS SOFTWARE IS PROVIDED BY FANNING SOFTWARE CONSULTING, INC. ''AS IS'' AND ANY        ;
;  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES    ;
;  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT     ;
;  SHALL FANNING SOFTWARE CONSULTING, INC. BE LIABLE FOR ANY DIRECT, INDIRECT,             ;
;  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED    ;
;  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;         ;
;  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND             ;
;  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT              ;
;  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS           ;
;  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                            ;
;******************************************************************************************;
FUNCTION SetUnion, set_a, set_b, $
    NORESULT=noresult, $
    SUCCESS=success
    
    Compile_Opt StrictArr, DefInt32
    
    ; Set up noresult value.
    IF N_Elements(noresult) EQ 0 THEN noresult = -1
    
    ; Error handling.
    Catch, theError
    IF theError NE 0 THEN BEGIN
      Catch, /CANCEL
      void = Error_Message()
      success = 0
      RETURN, noresult
    ENDIF
    
    ; Check parameters.
    IF N_Params() NE 2 THEN Message, 'Two input parameters or sets are required.'
    
    ; The input sets must be integers.
    IF (Size(set_a, /TYPE) GT 3) AND (Size(set_a, /TYPE) LT 12) THEN $
        Message, 'Set A must be an integer array.'
    IF (Size(set_b, /TYPE) GT 3) AND (Size(set_b, /TYPE) LT 12) THEN $
        Message, 'Set B must be an integer array.'

    ; If either of the sets is a scalar, make it a vector.
    IF N_Elements(set_a) EQ 1 && (Size(set_a))[0] EQ 0 THEN set_a = [set_a]
    IF N_Elements(set_b) EQ 1 && (Size(set_b))[0] EQ 0 THEN set_b = [set_b]

    ; Assume success.
    success = 1

    ; Find the ranges of the two sets.
    mina = Min(set_a, Max=maxa) 
    minb = Min(set_b, Max=maxb)
    
    ; If there is no overlap in the ranges, return NULL.
    IF (maxa LT minb) OR (maxb LT minA) THEN BEGIN
        success = 0
        RETURN, noresult
    ENDIF
   
   ; Find and return the unique indices in the two sets.
   h = Histogram([set_a, set_b], OMIN=omin)
   RETURN, Where(h GT 0) + omin 
   
END
