# ***************************************************************************************
# ***************************************************************************************
#
#		Name : 		addlibrary.py
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Date : 		11th January 2019
#		Purpose :	Add library to image
#
# ***************************************************************************************
# ***************************************************************************************

from labels import *
from imagelib import *
import os,re,sys

class ImageManager(object):
	def __init__(self):
		self.image = MemoryImage()
		self.dictionary = self.image.getDictionary()
	#
	#		Create source file
	#
	def createLibrarySource(self,library):
		hOut = open("__temp.asm","w")									# write file
		startAddress = self.image.getCodeAddress() 						# ORG for new code.
		hOut.write("\n\torg ${0:04x}\n\n".format(startAddress))			# output origin.
		sas = [x for x in self.dictionary.keys() if x[:4] == "sys_"]	# get system assignments
		sas.sort()														# neat :)
																		# write them out
		hOut.write("".join(["{0} = ${1:04x}\n".format(x,self.dictionary[x]["address"]) \
																				for x in sas]))
		hOut.write("\n")				
		for root,dirs,files in os.walk(library):						# scan for source files.
			for f in [x for x in files if x[-4:] == ".asm"]:			
				self.copyFile(hOut,root+os.sep+f)						# copy file, translating.
		hOut.close()

	# TODO: Invoke assembler
	# TODO: Load binary into image
	# TODO: Add new words and sys_ labels to dictionary (if sys_ exist check the same)
	# TODO: Save it out (on end)
	#
	#		Copy assembler file, translating as you go.
	#
	def copyFile(self,hOut,fileName):
		inDef = None
		for l in [x.rstrip() for x in open(fileName).readlines()]:		# work through file
			l = l.replace("\t"," ")										# process tabs
			if l.startswith("@"):										# handle commands.
				if l.startswith("@macro") or l.startswith("@wordx") or l.startswith("@wordr"):
					assert inDef is None,l 								# check state if new word	
					inDef = l
					m = re.match("^\@(\w+)\s+(.*)$",l)					# check format
					assert m is not None,l
																		# scramble name
					scramble = "_".join(["{0:02x}".format(ord(x)) for x in m.group(2).strip()])
					cType = m.group(1)
																		# write comment
					hOut.write("\n; {0} {1} {2} {0}\n\n".format("-----",m.group(2),cType))
																		# write label.
					hOut.write("define_{0}_{1}:\n".format(cType if cType == "macro" else "word",scramble))
					if cType == "wordx":								# wrapper for ix
						hOut.write("\tpop ix\n")
					if cType == "macro":								# expander for macro
						hOut.write("\tdb 0,0\n")						# easy spot marker
						hOut.write("\tcall sys_macroexpander\n")		# code to do it.
						hOut.write("\tdb end_{0}-start_{0}\n".format(scramble))
						hOut.write("start_{0}:\n".format(scramble))
				elif l == "@end":
					assert inDef is not None,inDef 						# check in word
					inDef = None
					if cType == "wordx":								# close wrappers.
						hOut.write("\tjp (ix)\n")
					if cType == "wordr":
						hOut.write("\tret\n")
					if cType == "macro":								# mark macro expand end.
						hOut.write("end_{0}:\n".format(scramble))
				else:
					assert False,"@ syntax "+l
			else:
				l = "\t"+l.strip() if l.startswith(" ") else l 			# reformat.
				hOut.write(l+"\n")

if __name__ == "__main__":
	im = ImageManager()
	im.createLibrarySource("core")





