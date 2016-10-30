# Modify the parameters in the spice files:

import os
import re

path = raw_input('Enter the Directory path to read files')

trans = []
threshold = dict()

while (True):
	inp1 = raw_input('Enter Transistors to modify the threshold or enter done')
	if inp1 == 'done' : break
	inp2 = raw_input('Enter the threshold value')
	inp1 = inp1+'\t'
	trans.append(inp1)
	threshold[inp1] = inp2 

print trans
print threshold


for file in os.listdir(path):
	if file.endswith(".sp"):
    		fhand = open(file, 'r')
		lines = fhand.readlines()
		fhand.close()
    		fhand = open(file, 'w')
		for line in lines:
			for i in range(len(trans)):
				line = line.rstrip()
				if line.startswith(trans[i]):
					print line
					str_match = re.findall('DELVTO=.*$', line)
					str_rep = 'DELVTO='+threshold[trans[i]]
					print str_match
					print str_rep
					line = line.replace(str_match[0], str_rep)
			fhand.write(line)
			fhand.write('\n')
		fhand.close()
