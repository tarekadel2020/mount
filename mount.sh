#!/bin/bash


## that script tested on arch linux
## Powered BY : Tarek adel       Date: 26-02-2021


mountusb(){
	selected=$(lsblk -rno size,name,mountpoint $usbdrives | awk '($1!~"M" && $1!~"K") {printf "%s%8s%12s\n", $2, $1, $3}' | dmenu -l 5 -i -p "USB Drivers: " | awk '{print $1}')
	
	if grep -qs $selected /proc/mounts  
then
	    
             sync
	     sudo umount /dev/$selected
	     grep -qs /media/$selected /proc/mounts || sudo rm -rf /media/$selected
	else
		##[ i -d /media/$selected ]  &&
		 sudo mkdir /media/$selected
		sudo mount /dev/$selected /media/$selected
		##sudo mount -o uid=$uid,gid=$gid  /dev/$selected /media/$selected
	fi
	
}



mountandroid(){	
	selected=$(echo "$anddrives" | dmenu -i -p "Which Android Device?" | cut -d : -f 1)
	sudo mkdir /media/$selected
	simple-mtpfs --device "$selected" "/media/$selected"
}

asktype(){
	case $(printf "USB\\nAndroid" | dmenu -i -p "Mount a USB drive or Android device?") in
	USB) mountusb ;;
	Android) mountandroid ;;
	esac

}



anddrives=$(simple-mtpfs -l 2>/dev/null)
usbdrives="$(ls -la /sys/block | grep usb | grep -o sd. | tail -1 | awk '{print "/dev/"$1}')"
uid=$(id -u)
gid=$(id -g)



if [ -z "$usbdrives" ]; then
	if [ -z "$anddrives" ];then
		echo "NO USB drive or Android device detected" | dmenu -i -p "USB Drivers: " && exit 1
	else
		echo "Android device(S) detected."
		mountandroid
	fi
else
	if [ -z "$anddrives" ]; then
		echo "USB drive(S) detected."
		mountusb
	else
		echo "Mountable USB drive(s) and Android device(s) detected"
		asktype
	fi
fi
