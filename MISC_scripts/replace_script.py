
#Modify the Relxpert model libraries

import os
import re

path = raw_input('Enter the Directory path to read files')
print path

for file in os.listdir(path):
    if file.startswith("relx."):
        print file
        fhand = open(file, 'r')
        lines = fhand.readlines()
        fhand.close()
        fhand = open(file, 'w')
        for line in lines:
            line = line.rstrip()
            if line.startswith("*xml"):
                print line
                str_match = re.findall('^\*xml', line)
                str_rep = 'xml'
                print str_match
                print str_rep
                line = line.replace(str_match[0], str_rep)
            if line.startswith("*relxpert"):
                print line
                str_match = re.findall('^\*relxpert', line)
                str_rep = 'relxpert'
                print str_match
                print str_rep
                line = line.replace(str_match[0], str_rep)
            fhand.write(line)
            fhand.write('\n')
        fhand.close()

