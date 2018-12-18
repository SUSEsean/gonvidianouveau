#!/bin/bash
# switch to nouveau driver for better battery life on the go
# Original Author - Cameron Seader
# Edited for new nVidia driver - Sean Rickerd

#copy xorg.conf to a backup copy and then delete xorg.conf
if [[ -e /etc/X11/xorg.conf ]]; then 
	mv /etc/X11/xorg.conf /etc/X11/xorg.conf.dgpu
else
	echo $'xorg.conf already backed up and moved. \n' 
fi

#fix up modprobe.d/50-blacklist.conf
#remove blacklist on nouveau driver with comment line
#if [[ -e /etc/modprobe.d/50-blacklist.conf ]]; then
sed -i 's/blacklist nouveau/#blacklist nouveau/g' /etc/modprobe.d/50-blacklist.conf
#blacklist the nvidia driver with uncomment of line
sed -i 's/#blacklist nvidia/blacklist nvidia/g' /etc/modprobe.d/50-blacklist.conf

#Uninstall nvidia driver
if [[ -e /usr/bin/nvidia-uninstall ]]; then 
nvidia-uninstall -s
else
	echo $'nvidia driver not installed. \n'
fi

#execute dracut to recreate initrd
if [[ -e /usr/bin/dracut ]]; then
	echo $'recreating the initrd... \n'
	dracut --force	
else
	echo $'dracut missing. please install.'
fi
