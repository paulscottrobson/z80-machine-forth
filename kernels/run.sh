sh build.sh
cp ../files/boot_clean.img boot.img
if [ -e boot.img ]
then
	wine ../bin/CSpect.exe -zxnext -cur -brk -exit -w3 ../files/bootloader.sna 
fi



