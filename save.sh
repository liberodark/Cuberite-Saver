#!/bin/bash
#
# About: Install and save cuberite server automatically
# Author: liberodark
# Project: Cuberite-Saver
# License: GNU GPLv3

 # init

dir_temp="/tmp/cuberite-$RANDOM"
dir_cube="/home/cuberite"
dir_backup="$dir_cube/backup"
link_arm="https://builds.cuberite.org/job/Cuberite%20Linux%20raspi-armhf%20Master/lastStableBuild/artifact/Cuberite.tar.gz"
link_x32="https://builds.cuberite.org/job/Cuberite%20Linux%20x86%20Master/lastStableBuild/artifact/Cuberite.tar.gz"
link_x64="https://builds.cuberite.org/job/Cuberite%20Linux%20x64%20Master/lastStableBuild/artifact/Cuberite.tar.gz"
server_arch=$(uname -m)
update_source="https://raw.githubusercontent.com/liberodark/Cuberite-Saver/master/save.sh"
version="1.1.2"

echo "Welcome on Cuberite-Saver $version"

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


 # stop cuberite
sudo service cuberite stop
echo "server stoped"

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

	if [ $server_arch = "x64" ]; then
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