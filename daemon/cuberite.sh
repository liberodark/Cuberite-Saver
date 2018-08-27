#!/bin/bash

##Configuration
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/cuberite.sh

## Download locations for different architectures.
X86LOC="http://builds.cuberite.org/job/Cuberite%20Linux%20x86%20Master/lastSuccessfulBuild/artifact/Cuberite.tar.gz"
X64LOC="http://builds.cuberite.org/job/Cuberite%20Linux%20x64%20Master/lastSuccessfulBuild/artifact/Cuberite.tar.gz"
ARMLOC="http://builds.cuberite.org/job/Cuberite%20Linux%20raspi-armhf%20Master/lastSuccessfulBuild/artifact/Cuberite.tar.gz"
X86LOCSHA="http://builds.cuberite.org/job/Cuberite%20Linux%20x86%20Master/lastSuccessfulBuild/artifact/Cuberite.tar.gz.sha1"
X64LOCSHA="http://builds.cuberite.org/job/Cuberite%20Linux%20x64%20Master/lastSuccessfulBuild/artifact/Cuberite.tar.gz.sha1"
ARMLOCSHA="http://builds.cuberite.org/job/Cuberite%20Linux%20raspi-armhf%20Master/lastSuccessfulBuild/artifact/Cuberite.tar.gz.sha1"

## Cuberite Directory
CUBERITEDIR="/root/MCServer/"
## Cache Directory
CACHEDIR="/root/.cuberiteupdate/"

# Check Root
if [ "$EUID" -ne 0 ]
  then 
	echo "$(tput setaf 3)Please run again as root.$(tput sgr0)"
  exit
fi

install(){
if hash screen 2>/dev/null;
then
if [ -d $CACHEDIR ]
	then
	  echo "* Cuberite is already installed."
exit
	fi

echo -n "* Checking dependencies..."
echo "	[$(tput setaf 2) OK $(tput sgr0)]"
 update
else
 echo "* Checking dependencies..."
 echo "$(tput setaf 3)Your system doesn't have screen installed, let's install it now.$(tput sgr0)"
 sleep 3
 apt-get update && apt-get install -y screen;
 echo -n "* Checking dependencies..."
 echo "	[$(tput setaf 2) OK $(tput sgr0)]"
 update
fi
}

## Send Function

send() {
    screen -S Cuberite -p 0 -X stuff "$1^M"
}

## Update Function

download() {
  # Download the current archive.
  echo -n "* Downloading Cuberite..."
  wget --quiet $ARCHLOC -O $CACHEDIR"Cuberite.tar.gz"
  echo "	[$(tput setaf 2) OK $(tput sgr0)]"
  # Extract the archive, clean up, and start Cuberite.
  echo -n "* Extracting downloaded archive..."
  tar -xf $CACHEDIR"Cuberite.tar.gz"
  echo "	[$(tput setaf 2) OK $(tput sgr0)]"
  echo -n "* Copying new files..."
  #cp -a "Server/." $CUBERITEDIR
  cp -r "Server/Plugins" $CUBERITEDIR
  cp -r "Server/webadmin" $CUBERITEDIR
  cp -r "Server/Prefabs" $CUBERITEDIR
  cp -r "Server/lang" $CUBERITEDIR
  cp -r "Server/Licenses" $CUBERITEDIR
  cp "Server/monsters.ini" $CUBERITEDIR
  cp "Server/items.ini" $CUBERITEDIR
  cp "Server/crafting.txt" $CUBERITEDIR
  cp "Server/furnace.txt" $CUBERITEDIR
  cp "Server/Cuberite" $CUBERITEDIR
  cp "Server/brewing.txt" $CUBERITEDIR
  cp "Server/buildinfo" $CUBERITEDIR
  cp "Server/BACKERS" $CUBERITEDIR
  cp "Server/CONTRIBUTORS" $CUBERITEDIR
  cp "Server/LICENSE" $CUBERITEDIR
  cp "Server/README.txt" $CUBERITEDIR
  rm -r "Server"
  echo "	[$(tput setaf 2) OK $(tput sgr0)]"
  # Server Updated
  echo "* Updated successfully!"
}

## Start Function
start() {
status
  if [[ ! $Pid ]] 
  then
  #Start Cuberite in a detached screen console with the session name Cuberite 
  cd $CUBERITEDIR
  echo -n "* Starting Cuberite server..."
  screen -dmS Cuberite ./Cuberite
  # Wait 20 secs to make sure sure Cuberite had time to fully start
  sleep 20
  echo "	[$(tput setaf 2) OK $(tput sgr0)]"
  else
  echo "* Cuberite is already running."
fi
}

## Status Function
status() {
# Check if Cuberite is running
Pid=$(pgrep "Cuberite") > /dev/null
if [[  $Pid ]]
# If Cuberite is running
then
   echo "* Checking server status...	[$(tput setaf 2) RUNNING $(tput sgr0)]"
else
# If Cuberite is NOT running
   echo "* Checking server status...	[$(tput setaf 1) STOPPED $(tput sgr0)]"
fi
return $Pid
}

## Stop Function
stop() {
  status
  if [[ $Pid ]] # Server is running, stop it
	then
	  # Find out the current Cuberite process and send stop command to Cuberite.
	  pid=`pgrep -o -x Cuberite`
	  send "stop$(printf \\r)"
	  echo -n "* Stopping Cuberite server..."
	  sleep 5
	  echo "	[$(tput setaf 2) OK $(tput sgr0)]"
   fi
} 

update() {
  status
  if [[ ! $Pid ]] # Server is NOT running, let's update
	then
	# Work out the current architecture and store it.
	CURRENTARCH=`uname -m`
	if [ $CURRENTARCH == "i686" ]
	then
	  ARCHLOC=$X86LOC
	  ARCHLOCSHA=$X86LOCSHA
	elif [ $CURRENTARCH == "x86_64" ]
	then
	  ARCHLOC=$X64LOC
	  ARCHLOCSHA=$X64LOCSHA
	elif [ $CURRENTARCH == "armv7l"  ] || [ $CURRENTARCH == "armv6l"  ]
	then
	  ARCHLOC=$ARMLOC
	  ARCHLOCSHA=$ARMLOCSHA
	else
	  echo "$(tput setaf 1)Arch not recognised. Please file a bug report with the output from uname -m and your machine type.$(tput sgr0)"
	  exit
	fi

	# Make sure the specified Cuberite directory exists.
	if [ ! -d $CUBERITEDIR ]
	then
	  # Make the directory.
	  mkdir $CUBERITEDIR
	fi

	# Check if the cache directory exists.
	if [ ! -d $CACHEDIR ]
	then
	  mkdir $CACHEDIR
	  download
	fi

	# Donwload thesha1 sum from the buildserver and check it against the current tar.
	wget --quiet $ARCHLOCSHA -O $CACHEDIR"Cuberite.tar.gz.sha1"
	cd $CACHEDIR
	sha1sum -c --status "Cuberite.tar.gz.sha1"
	rc=$?
	if [ $rc != 0 ]
	then
	  cd ..
	  # We don't have the most updated Cuberite version, download now.
	  download
	fi

	echo "$(tput setaf 2)* Cuberite has been installed and is up to date!$(tput sgr0)"
	start
    else
    echo "* Cuberite server is running, please stop it before updating.	[$(tput setaf 1) FAIL $(tput sgr0)]"

    fi
}

restart() {
status

# Server is running, restart it
  if [[ $Pid ]]
    then
    stop
    sleep 5
    start
# Server is NOT running, use start to start it
  elif [[ ! $Pid ]]
    then
	  echo "* Cuberite is not running, it can't be restarted.	[$(tput setaf 1) FAIL $(tput sgr0)]"
  fi
}

maintenance() {
status

# If the server is running
if [[ $Pid ]]
then
  send  "say The server is going down for maintenance in 5 minutes.$(printf \\r)"
  echo "$(tput setaf 3)The server is going down for maintenance in 5 minutes...$(tput sgr0)"
  sleep 60
  send "say The server is going down for maintenance in 4 minutes.$(printf \\r)"
  echo "$(tput setaf 3)The server is going down for maintenance in 4 minutes...$(tput sgr0)"
  sleep 60
  send "say The server is going down for maintenance in 3 minutes.$(printf \\r)"
  echo "$(tput setaf 3)The server is going down for maintenance in 3 minutes...$(tput sgr0)"
  sleep 60
  send "say The server is going down for maintenance in 2 minutes.$(printf \\r)"
  echo "$(tput setaf 3)The server is going down for maintenance in 2 minutes...$(tput sgr0)"
  sleep 60
  send "say The server is going down for maintenance in 1 minutes.$(printf \\r)"
  echo "$(tput setaf 3)The server is going down for maintenance in 1 minutes...$(tput sgr0)"
  sleep 30
  send "say The server is going down for maintenance in 30 seconds.$(printf \\r)"
  echo "$(tput setaf 3)The server is going down for maintenance in 30 seconds...$(tput sgr0)"
  sleep 15
  send "say Restarting the Server.$(printf \\r)"
  echo "$(tput setaf 3)Restarting Cuberite...$(tput sgr0)"
  sleep 15
  send "stop$(printf \\r)"
  echo "$(tput setaf 4)Stopping Cuberite...$(tput sgr0)"
  sleep 10
  echo "$(tput setaf 2)Done!$(tput sgr0)"
  update
fi
 echo "$(tput setaf 3)Use 'update' to fetch the latest build$(tput sgr0)"
}

logs() {
LOGDIR=logs
cd $CUBERITEDIR$LOGDIR
latest=$(ls -1t | head -1)
cat $latest
}


live() {
status
  if [[ $Pid ]]
    then
	echo "* Switching to the server session... "
	echo "$(tput setaf 3)* Press Ctrl+a+d to switch back.$(tput sgr0)"
	sleep 5
 	screen -r Cuberite
  else
	echo -n "* Switching to the server session... "
	echo "	[$(tput setaf 1) FAIL $(tput sgr0)]"
 	echo "* There isn't a server instance running."

  fi
}

help() {
cat << "EOF"


  ____ _   _ ____  _____ ____  ___ _____ _____ 
 / ___| | | | __ )| ____|  _ \|_ _|_   _| ____|
| |   | | | |  _ \|  _| | |_) || |  | | |  _|  
| |___| |_| | |_) | |___|  _ < | |  | | | |___ 
 \____|\___/|____/|_____|_| \_\___| |_| |_____|
                                               	
			 C++ Minecraft Server
                                                  
                        ``                        
                    .:sdNMds/.                    
                `:sdNMMMMMMMMNds:.                
            `:sdNMMMMMMMMMMMMMMMMNds:.            
        .:sdNMMMMMMMMNMMMMMMMMMMMMMMMNds:.        
    `:odNMMMMMMMMNho:oMMMMMMs:ohNMMMMMMMMNds/`    
   /MMMMMMMMMMdo:`   /MMMMMM+   `:odMMMMMMMMMM/   
   +MMMMMMMMMMds:`   `+ymmy/`   `:sdMMMMMMMMMM+   
   +MMMMMMMMMMMMMMds:.      .:sdMMMMMMMMMMMMMM+   
   +MMMMMMhdNMMMMMMMMNds::sdNMMMMMMMMNdhMMMMMM+   
   +MMMMMM/ `:odNMMMMMMMMMMMMMMMMNds:` /MMMMMM+   
   +MMMMMM/     `:sdNMMMMMMMMNds:`     /MMMMMM+   
   +MMMMMM/ `:o/.   `oMMMMMMs.   ./o:` /MMMMMM+   
   +MMMMMMhdNMMMMd.  +MMMMMM/  `mNMMMNdhMMMMMM+   
   +MMMMMMMMMMMMMN.  +MMMMMM/  `NMMMMMMMMMMMMM+   
   +MMMMMMMMMMds:`   +MMMMMM/   `/smMMMMMMMMMM+   
   /MMMMMMMMMMdo:`   +MMMMMM/   `:odMMMMMMMMMM/   
    `:odNMMMMMMMMNho:oMMMMMMo:odMMMMMMMMMNds/`    
        .:sdNMMMMMMMMMMMMMMMNMMMMMMMMNds:.        
            `:sdNMMMMMMMMMMMMMMMMNds:.            
                `:sdNMMMMMMMMNds:.                
                    .:sdMNds:.                    
                        ``                        
                                                  



    start 			-> Starts Cuberite Server.
    stop 			-> Stops Cuberite Server.
    restart 			-> Restarts Cuberite Server without updating or warning the online users (HARDRESET)
    update 			-> Updates Cuberite Server to the latest available build.
    maintenance 		-> Restarts Cuberite Server, sends a 5 minute warning to online users and updates Cuberite.
    status 			-> Shows the status of the server [online/offline].
    log   			-> View the latest logfile from the server.
    live   			-> Switch to the current server instance (Real time logs)
    install   			-> Install dependencies and Cuberite server.
    help 			-> Shows this help page.



    MORE INFORMATION:
    =================================================================
    Forum: 		https://forum.cuberite.org/
    Manual: 		https://book.cuberite.org/
    WebPage: 		http://cuberite.org/
    Report Issues:	https://github.com/cuberite/cuberite/issues
    =================================================================

EOF
}

case "$1" in
  (start) 
    start
    exit 0
    ;;
  (stop)
    stop
    exit 0
    ;;
 (update)
    update
    exit 0
    ;;
 (restart)
    restart
    exit 0
    ;;
 (maintenance)
    maintenance
    exit 0
    ;;
 (status)
    status
    exit 0
    ;;
 (log)
    logs
    exit 0
    ;;
 (live) 
    live
    exit 0
    ;;
 (install) 
    install
    exit 0
    ;;
 (help)
    help
    exit 0
    ;;
  (*)
    echo "Usage: $0 {start|stop|update|restart|maintenance|status|log|live|install|help}"
    exit 2
    ;;
esac
