#!/bin/bash

# TODO add simulation mode where only logs are
# displayed

#[ -z "$progsfile" ] && progsfile="http://192.168.21.100/progs.csv"
progsfile="progs.csv"

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
	pacman --noconfirm --needed -Syu >/dev/null 2>&1
}

addUser() {
	useradd -mg wheel "$username"
	echo "$username:$password" | chpasswd
}

installPackage() {
	pacman --noconfirm --needed -S "$1" >/dev/null 2>&1
}

unInstallPackage() {
	pacman --noconfirm -Rns "$1" >/dev/null 2>&1
}

pacmanInstall() {
	printf "($n of $progsNo) \tInstalling $1 from official repository.\n"
	printf "\t\t$1 $2\n"
	loading &

	sleep 5
	#installPackage "$1"

	kill $!
}

mainInstallation() {
	#([ -f "$progsfile" ] && cp "$progsfile" /tmp/progs.csv) || curl -Ls "$progsfile" | tail -n +2  > /tmp/progs.csv
	([ -f "$progsfile" ] && sed -E "/^#/d" "$progsfile" > /tmp/progs.csv) || curl -Ls "$progsfile" | tail -n +2  > /tmp/progs.csv
	progsNo=$(cat /tmp/progs.csv | wc -l)
	n=0
	while IFS="," read tag program description; do
		# TODO usunąć znaki " z opisu
#		echo "tag $tag"
#		echo "prog $program"
		#echo "desc $description"
		description=$(echo "$description" | sed "s/\(^\"\|\"$\)//g")
		n=$((n+1))
		case "$tag" in

			"A")
				echo "AUR unsupported."
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

addDoasPrivilege() {
	# TODO make sure variable is set
	echo "permit persist $username as root" > /etc/doas.conf
}

#getUserAndPassword
#beforeInstallPreparation
#addUser
mainInstallation
#addDoasPrivilege
