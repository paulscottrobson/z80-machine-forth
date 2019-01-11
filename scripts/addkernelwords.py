# ***************************************************************************************
# ***************************************************************************************
#
#		Name : 		addkernelwords.py
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Date : 		11th January 2019
#		Purpose :	add kernel words to the dictionary.
#
# ***************************************************************************************
# ***************************************************************************************

from labels import *
from imagelib import *

print("Importing system labels from kernel.")
#
#		Get all system labels
#
sysLabels = LabelExtractor("kernel.lst").getLabels()
labels = [x for x in sysLabels.keys() if x[:4] == "sys_"]
#
#		Sort into code order
#
labels.sort(key = lambda x:sysLabels[x])
#
#		Now insert them
#
image = MemoryImage()
for lbl in labels:
	image.addDictionary(lbl,image.getCodePage(),sysLabels[lbl],False)
#
#		Write out
#
image.save()
