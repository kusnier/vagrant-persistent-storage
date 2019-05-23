#!/bin/bash

pushd sample-vm > /dev/null

if [[ "$OSTYPE" == "linux-gnu" ]]; then
        VBOXMANAGE=`which vboxmanage`
elif [[ "$OSTYPE" == "darwin"* ]]; then
        VBOXMANAGE=`which vboxmanage`
elif [[ "$OSTYPE" == "cygwin" ]]; then
		VBOXMANAGE="/c/Program Files/Oracle/VirtualBox/VBoxManage.exe"
elif [[ "$OSTYPE" == "msys" ]]; then
		VBOXMANAGE="/c/Program Files/Oracle/VirtualBox/VBoxManage.exe"
elif [[ "$OSTYPE" == "win32" ]]; then
		VBOXMANAGE="/c/Program Files/Oracle/VirtualBox/VBoxManage.exe"
elif [[ "$OSTYPE" == "freebsd"* ]]; then
        VBOXMANAGE=`which vboxmanage`
else
        echo Seriously, what the hell are you running me on????
		exit 1
fi

FILES=*.vagrantfile
for f in $FILES
do
	echo Testing $f
	VAGRANT_VAGRANTFILE="$f" vagrant up --no-color > $f.log
	VAGRANT_VAGRANTFILE="$f" vagrant ssh -- "mount | grep -q mysql"
	RESULT=$?
	if [ $RESULT -eq 0 ]; then
		echo ...[PASSED]
	else
		echo ...[FAILED]
	fi
	VAGRANT_VAGRANTFILE="$f" vagrant destroy -f --no-color >> $f.log && rm -fv virtualdrive.vdi >> $f.log 2>&1 
done


popd > /dev/null
