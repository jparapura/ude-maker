#!/bin/bash

# TODO fix tabs
# TODO add simulation mode where only logs are
# displayed

# TODO order funcitons in order of calling

# TODO add following line somewhere. maybe it won't be necessary. i dunno
# echo hsts-file \= "$XDG_CACHE_HOME"/wget-hsts >> "$XDG_CONFIG_HOME/wgetrc"

# TODO configure slock
# TODO shorten grub timeout
# TODO sshd configuration
# TODO set default programs by xdg-mime

#progsfile="progs.csv"
#[ -z "$progsfile" ] || progsfile="http://192.168.21.100/progs.csv"
# TODO consider changing name to progsurl
progsfile="http://192.168.21.100/progs.csv"
dotfilesRepo="https://github.com/tangens90/uniform-desktop-environment.git"
logfile="/root/log.log"

# TODO understand this
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

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

requireUserAndPass() {
    if [ -z "$username" ] || [ -z $password ]; then
        getUserAndPassword
        requireUserAndPass
    fi
}

getUserAndPassword() {
	# TODO make sure these are valid
	# TODO set default username to ude
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
    requireUserAndPass

	echo "Installing Paru. Paru is an AUR helper."
	rm -rf /tmp/paru 2> /dev/null
	cd /tmp
	curl -LO https://aur.archlinux.org/cgit/aur.git/snapshot/paru-bin.tar.gz >> "$logfile" 2>&1
	tar xzvf paru-bin.tar.gz >> "$logfile" 2>&1
	cd paru-bin
	chown -R "$username:wheel" /tmp/paru-bin
	loading &
	sudo -u "$username" makepkg --noconfirm -si >> "$logfile" 2>&1
	kill $!
	cd ${SCRIPT_DIR}

	# alternatively paru could be compiled from the source
	# but it takes much longer. if you don't care, compilation
	# from the source can be done as so:

	# curl -LO https://aur.archlinux.org/cgit/aur.git/snapshot/paru.tar.gz >> "$logfile" 2>&1
	# tar xzvf paru.tar.gz >> "$logfile" 2>&1
	# cd paru
	# chown -R "$username:wheel" /tmp/paru
	# sudo -u "$username" makepkg --noconfirm -si >> "$logfile" 2>&1
}

addUser() {
    requireUserAndPass

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
    requireUserAndPass

	printf "($n of $progsNo) \tInstalling $1 from AUR.\n"
	printf "\t\t$1 - $2\n"

	loading &
	sudo -u "$username" paru -S --noconfirm "$1" >> "$logfile" 2>&1
	kill $!
}

gitInstall() {
    requireUserAndPass

	printf "($n of $progsNo) \tInstalling $1 using git.\n"
	printf "\t\t$1 - $2\n"

	loading &
	progname=$(basename "$1" .git)
    sudo -u ${username} mkdir -p /home/${username}/.local/src
	cd $_

	sudo -u ${username} git clone "$1" > /dev/null 2>&1
    cd ${progname}
# poprawić na jakiś rodzaj kompilacji
	make clean install > /dev/null 2>&1
	cd ${SCRIPT_DIR}
	kill $!
}

pacmanInstall() {
	printf "($n of $progsNo) \tInstalling $1 from the official repository.\n"
	printf "\t\t$1 - $2\n"

	installPackage "$1"
}

mainInstallation() {
    requireUserAndPass

	#([ -f "$progsfile" ] && cp "$progsfile" /tmp/progs.csv) || curl -Ls "$progsfile" | tail -n +2  > /tmp/prog.csv
	# TODO poprawić to miejsce
	#([ -f "$progsfile" ] && sed -E "/^#/d" "$progsfile" > /tmp/progs.csv) || curl -Ls "$progsfile" | tail -n +2  > /tmp/progs.csv
	# if [ -e "progs.csv" ]; then
	# 	# cat progs.csv | tail -n +2 > /tmp/progs.csv
	# else
	# 	curl -Ls "$progsfile" | tail -n +2 > /tmp/progs.csv
	# fi
	cd ${SCRIPT_DIR}
    cat progs.csv | sed '/^#/d' > /tmp/progs.csv
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
				gitInstall "$program" "$description"
				;;

			*)
				pacmanInstall "$program" "$description"
				;;
		esac
	done < /tmp/progs.csv
}

pullDotfilesRepo() {
    requireUserAndPass

	echo "Downloading dotfiles repo."
	loading &
	echo ".cfg" >> /home/${username}/.gitignore
	git clone --bare ${dotfilesRepo} /home/${username}/.cfg > /dev/null 2>&1
	rm /home/${username}/.bash* > /dev/null 2>&1
	# TODO consider config alias for what's below
	git --git-dir=/home/${username}/.cfg/ --work-tree=/home/${username} checkout
	git --git-dir=/home/${username}/.cfg/ --work-tree=/home/${username} config --local status.showUntrackedFiles no
	sudo chown ${username}:wheel -R /home/${username} 
	rm /home/${username}/.gitignore
	kill $!
}

addRootPrivilege() {
    requireUserAndPass

	# TODO make sure variable is set
	echo "permit persist $username as root" > /etc/doas.conf
	sed -i "/# ude-maker/d" /etc/sudoers
	# permission below will be changed to version without
	# NOPASSWD in finish function
	echo "%wheel ALL=(ALL) NOPASSWD: ALL    # ude-maker" >> /etc/sudoers
}

finish() {
    echo "xdxd"
    # TODO do i really need to disable sudo?
	# sed -i "/# ude-maker/d" /etc/sudoers
	# echo "%wheel ALL=(ALL) ALL    # ude-maker" >> /etc/sudoers
	# TODO delete go folder in user's home folder
}

getUserAndPassword
beforeInstallPreparation
addUser
addRootPrivilege
installParu
mainInstallation
pullDotfilesRepo
# finish
