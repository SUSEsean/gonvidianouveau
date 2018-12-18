#!/bin/bash
# switch to nvidia proprietary driver for office or battery connected desktop
# Original Author - Cameron Seader
# Edited for new nVidia driver - Sean Rickerd

#copy xorg.conf.dgpu to xorg.conf to resume nvidia driver state
if [[ -e /etc/X11/xorg.conf.dgpu ]]; then 
	mv /etc/X11/xorg.conf.dgpu /etc/X11/xorg.conf
else
	echo $'xorg.conf.dgpu doesn\'t exist, or has been moved to xorg.conf already.' 
fi

#fix up modprobe.d/50-blacklist.conf
#blacklist the nouveau driver
if grep -x "#blacklist nouveau" /etc/modprobe.d/50-blacklist.conf; then
	sed -i 's/#blacklist nouveau/blacklist nouveau/g' /etc/modprobe.d/50-blacklist.conf
	echo $'nouveau driver blacklisted. \n'
else
	echo $'\nnouveau driver may already be blacklisted? Checking...'
	#checking for blacklisted nouveau driver
	if grep -x "blacklist nouveau" /etc/modprobe.d/50-blacklist.conf; then
		echo $'...Yes. nouveau driver already blacklisted. \n'
	else
		echo $'...No. nouveau driver needs blacklisted. Doing that now...\n'
		echo $'blacklist nouveau' >> /etc/modprobe.d/50-blacklist.conf
		echo $'...Done. \n'
	fi
fi	
#remove the blacklist on the nvidia driver with comment line
if grep -x "blacklist nvidia" /etc/modprobe.d/50-blacklist.conf; then
	sed -i 's/blacklist nvidia/#blacklist nvidia/g' /etc/modprobe.d/50-blacklist.conf
	echo $'\n removed nvidia driver from blacklist.'
else
	echo $'nvidia driver was already removed from blacklist? checking...'
	#checking for blacklisted nvidia driver
	if grep -x "#blacklist nvidia" /etc/modprobe.d/50-blacklist.conf; then
		echo $'...Yes. blacklisting already removed for nvidia driver. \n'	
	else	
		echo $'...No. adding reference for nvidia driver blacklisting \n'	
		echo $'#blacklist nvidia' >> /etc/modprobe.d/50-blacklist.conf
	fi
fi


#execute dracut to reload the initial ram disk after changes and driver install

if [[ -e /usr/bin/dracut ]]; then
	echo $'recreating the initrd... \n'
	dracut --force	
else
	echo $'dracut missing. please install.'
fi

#check for loaded nouveau driver before installing nvidia driver
/sbin/lsmod | grep -q nouveau
rc=$?
if [[ ${rc} -eq 0 ]]; then
	echo $'\n \n nouveau driver is running. You must reboot to runlevel 3 and proceed with installing the nvidia driver. \n'
	exit
else
	echo $'\n Installing the nvidia driver. \n'

fi

#Install nvidia driver
if [[ -e /home/sean/Downloads/NVIDIA-Linux-x86_64-415.23.run ]]; then 
	/home/sean/Downloads/NVIDIA-Linux-x86_64-415.23.run -a -q
	# remove artifact of running the nvidia installer in runlevel 5
	if [[ -e /etc/modprobe.d/nvidia.conf ]]; then
		rm /etc/modprobe.d/nvidia.conf
	fi
else
	echo $'\n nvidia driver doesn\'t exist. \n'
fi

#execute dracut to reload the initial ram disk after changes and driver install

if [[ -e /usr/bin/dracut ]]; then
	echo $'recreating the initrd... \n'
	dracut --force	
else
	echo $'dracut missing. please install.'
fi
