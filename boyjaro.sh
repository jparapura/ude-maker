#!/bin/bash

# TODO add simulation mode where only logs are
# displayed

# TODO order funcitons in order of calling

#progsfile="progs.csv"
#[ -z "$progsfile" ] || progsfile="http://192.168.21.100/progs.csv"
progsfile="http://192.168.21.100/progs.csv"
logfile="/root/log.log"

[ -f "$logfile" ] && rm "$logfile"

loading() {
	chars="/-\|"

	while :; do
	  for (( i=0; i<${#chars}; i++ )); do
		echo -en "${chars:$i:1}" "\r"
		sleep 0.5
	  done
	done
}

getUserAndPassword() {
	# TODO make sure these are valid
	echo "Username: "
	read username
	echo "Password: "
	read password
}

beforeInstallPreparation() {
	echo "Updating the system."
	# unc
	loading &
	pacman --noconfirm --needed -Syu >> "$logfile" 2>&1
	kill $!

	for x in curl base-devel git opendoas; do
		echo "Installing $x which is required to install and configure other programs."
		installPackage "$x"
	done
}

installParu() {
	[ -f "/usr/bin/paru" ] && return 0
	echo "Installing Paru. Paru is an AUR helper."
	rm -rf /tmp/paru 2>/dev/null
	cd /tmp
	git clone https://aur.archlinux.org/paru.git >> "$logfile" 2>&1
	cd paru
	chown -R "$username:wheel" /tmp/paru
	loading &
	sudo -u "$username" makepkg --noconfirm -si >> "$logfile" 2>&1
	kill $!
	cd 
}

addUser() {
	useradd -mg wheel "$username"
	echo "$username:$password" | chpasswd
}

installPackage() {
	loading &
	# unc
	pacman --noconfirm --needed -S "$1" >> "$logfile" 2>&1
	#sleep 5
	kill $!
}

# TODO uninstall everything
unInstallPackage() {
	pacman --noconfirm -Rns "$1" >> "$logfile" 2>&1
}

aurInstall() { \
	printf "($n of $progsNo) \tInstalling $1 from AUR.\n"
	printf "\t\t$1 $2\n"

	loading &
	sudo -u "$username" paru -S --noconfirm "$1" >> "$logfile" 2>&1
	kill $!
}

pacmanInstall() {
	printf "($n of $progsNo) \tInstalling $1 from the official repository.\n"
	printf "\t\t$1 $2\n"

	installPackage "$1"
}

mainInstallation() {
	#([ -f "$progsfile" ] && cp "$progsfile" /tmp/progs.csv) || curl -Ls "$progsfile" | tail -n +2  > /tmp/prog.csv
	# TODO poprawić to miejsce
	#([ -f "$progsfile" ] && sed -E "/^#/d" "$progsfile" > /tmp/progs.csv) || curl -Ls "$progsfile" | tail -n +2  > /tmp/progs.csv
	curl -Ls "$progsfile" | tail -n +2  > /tmp/progs.csv
	progsNo=$(cat /tmp/progs.csv | wc -l)
	n=0
	while IFS="," read tag program description; do
#		echo "tag $tag"
#		echo "prog $program"
		#echo "desc $description"
		description=$(echo "$description" | sed "s/\(^\"\|\"$\)//g")
		n=$((n+1))
		case "$tag" in

			"A")
				aurInstall "$program" "$description"
				;;

			"G")
				echo "Git unsupported."
				;;

			*)
				pacmanInstall "$program" "$description"
				;;
		esac
	done < /tmp/progs.csv
}

addRootPrivilege() {
	# TODO make sure variable is set
	echo "permit persist $username as root" > /etc/doas.conf
	sed -i "/# boyjaro/d" /etc/sudoers
	echo "%wheel ALL=(ALL) ALL    # boyjaro" >> /etc/sudoers
}

getUserAndPassword
beforeInstallPreparation
addUser
addRootPrivilege
installParu
mainInstallation
