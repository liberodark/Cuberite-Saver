#!/bin/bash
#
# About: Install and save cuberite server automatically
# Author: liberodark
# Project: Cuberite-Update
# License: GNU GPLv3

 # init

dir_temp="/tmp/cuberite-$RANDOM"
dir_cube="/home/cuberite"
dir_backup="$dir_cube/backup"
link_arm="https://builds.cuberite.org/job/Cuberite%20Linux%20raspi-armhf%20Master/lastStableBuild/artifact/Cuberite.tar.gz"
link_x32="https://builds.cuberite.org/job/Cuberite%20Linux%20x86%20Master/lastStableBuild/artifact/Cuberite.tar.gz"
link_x64="https://builds.cuberite.org/job/Cuberite%20Linux%20x64%20Master/lastStableBuild/artifact/Cuberite.tar.gz"
server_arch=$(uname -m)
update_source="https://raw.githubusercontent.com/liberodark/Cuberite-Update/master/update.sh"
version="1.1.3"

echo "Welcome on Cuberite-Update $version"

 # make update if asked
if [ "$1" = "noupdate" ]; then
	update_status="false"
else
	update_status="true"
fi ;

 # update updater
 if [ "$update_status" = "true" ]; then
 	wget -O $0 $update_source
 	$0 noupdate
 	exit 0
 fi ;
 
 # Check OS & wget

which wget &> /dev/null

if [ $? != 0 ]; then
  echo "wget is not Installed"
   distribution=$(cat /etc/issue | head -n +1 | awk '{print $1}')

  if [ "$distribution" = "Manjaro" ]; then
    sudo pacman -S wget # Manjaro / Arch Linux
    
  elif [ "$distribution" = "Ubuntu" ]; then
    sudo apt install wget # Ubuntu / Debian
    
  elif [ "$distribution" = "OpenSuse" ]; then
    sudo yum install wget # OpenSuse / CentOS
    
  elif [ "$distribution" = "Fedora" ]; then
    sudo dnf install wget # Fedora
    
  elif [ "$distribution" = "CentOS" ]; then
    sudo yum install wget # OpenSuse / CentOS
    
  elif [ "$distribution" = "Debian" ]; then
    sudo apt install wget # Ubuntu / Debian
    
  elif [ "$distribution" = "Gentoo" ]; then
    su -c emerge wget # Gentoo
  fi
  else
echo "wget is Installed"
fi

# Check OS & tar

which tar &> /dev/null

if [ $? != 0 ]; then
  echo "tar is not Installed"
   distribution=$(cat /etc/issue | head -n +1 | awk '{print $1}')

  if [ "$distribution" = "Manjaro" ]; then
    sudo pacman -S tar # Manjaro / Arch Linux
    
  elif [ "$distribution" = "Ubuntu" ]; then
    sudo apt install tar # Ubuntu / Debian
    
  elif [ "$distribution" = "OpenSuse" ]; then
    sudo yum install tar # OpenSuse / CentOS
    
  elif [ "$distribution" = "Fedora" ]; then
    sudo dnf install tar # Fedora
    
  elif [ "$distribution" = "CentOS" ]; then
    sudo yum install tar # OpenSuse / CentOS
    
  elif [ "$distribution" = "Debian" ]; then
    sudo apt install tar # Ubuntu / Debian
    
  elif [ "$distribution" = "Gentoo" ]; then
    su -c emerge tar # Gentoo
  fi
  else
echo "tar is Installed"
fi

# Check OS & sudo

which sudo &> /dev/null

if [ $? != 0 ]; then
  echo "sudo is not Installed"
   distribution=$(cat /etc/issue | head -n +1 | awk '{print $1}')

  if [ "$distribution" = "Manjaro" ]; then
    su pacman -S sudo # Manjaro / Arch Linux
    
  elif [ "$distribution" = "OpenSuse" ]; then
    su yum install sudo # OpenSuse / CentOS
    
  elif [ "$distribution" = "Fedora" ]; then
    su dnf install sudo # Fedora
    
  elif [ "$distribution" = "CentOS" ]; then
    su yum install sudo # OpenSuse / CentOS
    
  elif [ "$distribution" = "Gentoo" ]; then
    su -c emerge sudo # Gentoo
  fi
  else
echo "sudo is Installed"
fi

# Check Cuberite Service
which service cuberite &> /dev/null

if [ "$?" != 0 ]; then
    echo "Cuberite Service not Installed"
    wget https://raw.githubusercontent.com/liberodark/Cuberite-Update/master/daemon/cuberite
    wget https://raw.githubusercontent.com/liberodark/Cuberite-Update/master/daemon/cuberite.sh
    mv cuberite /etc/init.d/
    chmod 677 /etc/init.d/cuberite
    update-rc.d cuberite defaults
    mv cuberite.sh /root/
else
    echo "Cuberite Service is Installed"
fi

# Check Cuberite
which ls /home/cuberite/ &> /dev/null

if [ "$?" != 0 ]; then
    echo "Cuberite not Installed"
    mkdir /home/cuberite/
else
    echo "Cuberite is Installed"
fi

# Stop Cuberite
sudo service cuberite stop &> /dev/null

if [ "$?" != 0 ]; then
    echo "Cuberite is not Stoped"
else
    echo "Cuberite is Stoped"
fi

 # backup cuberite

 	# make dir
	if [ ! -e $dir_backup ]; then
		mkdir $dir_backup
	fi ;

	# remove old backups
	if [ $( ls $dir_backup/*.tar.gz | wc -l ) -gt 9 ]; then
		rm $(ls $dir_backup/*.tar.gz | head -n $(( $(ls $dir_backup/*.tar.gz | wc -l) -9 )))
		echo "old backups deleted"
	fi ;

	# make backup
	tar -zcvf "$dir_backup/backup-$(date +%Y-%m-%d-%H-%M).tar.gz" --exclude="backup*" $dir_cube/
	echo "backup done."
	
# download last update

	# make temp directory for update
	if [ ! -e $dir_temp ]; then
		mkdir $dir_temp
	else
		echo "The folder '$dir_temp' can't be created."
		exit 1
	fi ;

	# downloading
	cd $dir_temp

	if [ $server_arch = "x86_64" ]; then
		wget $link_x64
	else
		wget $link_x32
	fi ;

	echo "newest version downloaded."

	# extracting
	tar -xzf Cuberite.tar.gz && mv Server/* .
	rm Cuberite.tar.gz
	if [ ! -e "Cuberite" ]; then
		cd *
	fi ;
	echo "files extracted."

	# moving to ts3_dir
	cp -fr * $dir_cube
	echo "server updated"

# cleaning temp files
rm -fr $dir_temp

# starting cuberite
sudo service cuberite start
echo "server started"