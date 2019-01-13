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
zasm -buw build/kernel.asm -o boot.img -l boot.lst
if [ -e boot.img ]
then
	cp boot.img ../files/boot_clean.img
	python ../scripts/showdictionary.py
fi
