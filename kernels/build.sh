#
#		Tidy up
#
rm boot.img ../files/*.img build/*
#
#		Make source file
#
python ../scripts/makekernel.py kernel
#
#		Assemble the kernel
#
zasm -buw work/kernel.asm -o work/boot.img -l work/boot.lst
if [ -e work/boot.img ]
then
	cp work/boot.img ../files/boot_clean.img
	python ../scripts/showdictionary.py work/boot.img
fi
