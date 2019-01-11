#
#		Tidy up
#
rm boot.img ../files/*.img 
#
#		Assemble the kernel
#
zasm -buw kernel.asm -l kernel.lst -o boot.img
#
#		Insert vocabulary into the image file.
#
python ../scripts/addkernelwords.py
#
#		Copy resulting boot image to files.
#
if [ -e boot.img ]
then
	cp boot.img ../files/boot_clean.img
	python ../scripts/showdictionary.py
fi
