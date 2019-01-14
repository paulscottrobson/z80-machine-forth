# ***************************************************************************************
# ***************************************************************************************
#
#		Name : 		makekernel.py
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Date : 		11th January 2019
#		Purpose :	Kernel source file builder.
#
# ***************************************************************************************
# ***************************************************************************************

import re,sys,os

buildDir = "."+os.sep+"work"											# where to build kernel.asm
compDir = ".."+os.sep+"components"										# where the components are.
#
#		Work out components list
#
compList = [x.lower() for x in sys.argv[1:] if x.lower() != "kernel"]	# copy, except kernel
compList.sort()															# sort it
compList.insert(0,"kernel")												# add kernel.
print("Building from components {0}".format(",".join(compList)))		# display it.
#
hOut = open(buildDir+os.sep+"kernel.asm","w")							# open target file.
wordList = {} 															# List of words defined.
for comp in compList:													# for each component.
	fileList = []														# get the files.
	for root,dirs,files in os.walk(compDir+os.sep+comp):
		for f in [x for x in files if x.endswith(".asm")]:
			fileList.append(root+os.sep+f)
	fileList.sort()														# sort into order.
	print("\tBuilding {0}".format(comp))
	for f in fileList:													# work through all files
		inDefinition = False											# not in a definition.
		for l in [x.rstrip() for x in open(f).readlines()]:				# scan file.
			if l.startswith("@"):										# requires special handling.
				if l.startswith("@wordx") or l.startswith("@wordr") or l.startswith("@macro"):
					l = l.replace("\t"," ")								# preprocess
					assert not inDefinition,l 							# check out of def
					lOpen = l 											# remember it
					inDefinition = True 								# in def
					word = re.split("\s+",l)[1].strip()					# get name and scramble it
					scramble = "_".join(["{0:02x}".format(ord(x)) for x in word])
					if l.startswith("@macro"):							# macros are immediate.
						word = word + "::I"
					hOut.write("define_{0}:\n".format(scramble))		# definition create and add
					wordList[word.lower()] = "define_"+scramble
					if l.startswith("@wordx"):							# preamble (x)
						hOut.write("\tpop ix\n")
					if l.startswith("@macro"):							# preamble (macro)
						hOut.write("\tld   b,end_{0}-start_{0}\n".format(scramble))
						hOut.write("\tcall FARMacroExpander\n")
						hOut.write("start_{0}:\n".format(scramble))

				elif l == "@end":										# end of def
					assert inDefinition									# check it
					inDefinition = False
					if lOpen.startswith("@macro"):						# terminate @macro
						hOut.write("end_{0}:\n".format(scramble))
					if lOpen.startswith("@wordr"):						# terminate @wordr
						hOut.write("\tret\n")
					if lOpen.startswith("@wordx"):						# terminate @wordx
						hOut.write("\tjp (ix)\n")

				else:
					raise Exception("Line ?? "+l)
			else:
				hOut.write(l.replace("\t","  ")+"\n")

print("\tBuilding dictionary.")
hOut.write("FreeMemory:\n")												# mark free memory
hOut.write("\torg $C000\n")												# advance to dictionary
wkeys = [x for x in wordList.keys()]									# list of words, sort
wkeys.sort()
for w in wkeys:															# work through
	iByte = len(w)														# byte 4 and name
	lbl = wordList[w]
	if w.endswith("::i"):												# if it's immediate.
		w = w[:-3]
		iByte = len(w) + 0x80
	hOut.write("\tdb    {0},$22\n".format(len(w)+5))					# offset,page
	hOut.write("\tdw    {0}\n".format(lbl))								# address
	hOut.write("\tdb    {0},\"{1}\"\n\n".format(iByte,w))				# len/info + name

hOut.write("\tdb  0\n")													# end of dictionary
hOut.close()