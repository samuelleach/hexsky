function strc, input, format=format

output = strcompress(string(input, format=format), /rem)

return, output

end
