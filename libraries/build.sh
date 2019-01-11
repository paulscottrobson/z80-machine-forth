pushd ../bootloader
sh build.sh
popd
pushd ../kernel
sh build.sh
popd
#
#	Copy empty from files
#
cp ../files/boot_clean.img boot.img
python ../scripts/addlibrary.py core 
zasm -buw __temp.asm -o __temp.bin -l __temp.lst