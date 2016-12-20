#!/bin/bash
# Tyler Shupe system configurator
# 07-09-16
# This script installs repos and packages as well as copy over config
# files
# This script should be placed in the directory with all of the config files

if [ "$1" == "--pkgs-only" ]; then
	echo "Installing packages only"
	pkgonly=true
else
	pkgonly=false
fi


if [[ $EUID -ne 0 ]]; then
	echo "You must be root to install packages" 1>&2
	exit 2
fi

# Variables
GREEN='\033[0;32m'
RESET='\033[0;37m'
USR="shupet"
PACKMGR="dnf"
OPTS="install -y"
PKGS=(
	#shells
	zsh
	fish
	
	#editors
	vim
	gedit
	atom
	
	#monitor tools
	htop
	wireshark
	wavemon
	nmap
	xsensors
	lm_sensors
	
	# devel
	gcc
	gcc-c++
	make
	cmake
	#drush
	git
	python
	python3
	
	# web tools
	php
	
	# browsers
	firefox 
	google-chrome-stable
	vivaldi-stable
	
	#terminals
	terminator
	guake
	
	# media
	vlc
	ImageMagick
	california
		
	# tools
	gnome-tweak-tool
	wget
	dconf-editor
	thunar
	aspell
	irssi
	dnf-plugins*
	
	# Latex
	texworks
	texlive-base
	bibtex

	# chrome deps
	xdg-utils
	libXScrnSaver
	redhat-lsb

)

echo -e "${GREEN}Installing config files in ${RESET}/home/${USR}/"
echo -e "${GREEN}Using package manager ${RESET}${PACKMGR}"
echo -e "${GREEN}Using options ${RESET}${OPTS}"
echo -e "${GREEN}Installing packages:${RESET}"
for x in  ${PKGS[@]}
do
	echo -e "\t$x"
done
sleep 1

# Repos
echo "Phase: Repo installation."
## rpmfusion
echo -e "\tRPMFusion"
su -c 'dnf install -y http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm'

## vivaldi
echo -e "\tVivaldi"
dnf config-manager --add-repo=http://repo.vivaldi.com/stable/rpm/x86_64/

## atom copr
echo -e "\tAtom"
dnf copr enable mosquito/atom -y

echo "Phase 1 Complete"
# Packages
echo "Phase 2: Packages."
sleep 1
for x in ${PKGS[@]}
do
	dnf install -y $x
done
## oh-my-zsh
sudo -H -u $USR bash -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

## chrome
echo -e "\tGoogle Chrome"
dnf install -y xdg-utils libXScrnSaver redhat-lsb
rpm -ivh https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm

echo "Phase 2 Complete."
sleep 1

# Misc
echo "Phase 3: Misc"

## /usr/local/bin/
echo "copying /usr/local/bin files."
cp -v ./usrlocalbin/* /usr/local/bin/

## done with pkgs
if [ "$pkgonly" == true ]; then
	echo "Finished package installation."
	exit 0
fi

## .local/bin/
echo "copying .local/bin files."
mkdir -p /home/$USR/.local/bin/
chown $USR:$USR /home/$USR/.local/bin/
cp -v ./localbin/* /home/$USR/.local/bin/


echo "Phase 3 Complete."
echo "Configuration Complete"



# Config files
echo "Phase 4: Config files"
## htop
mkdir -vp /home/$USR/.config/htop/
#chown -R $USR /home/$USR/.config/
cp -v ./htoprc /home/$USR/.config/htop/

## terminator
mkdir -vp /home/$USR/.config/terminator/
cp -v ./terminator/config /home/$USR/.config/terminator/

## vim
mkdir -vp /home/$USR/.vim/colors/
#chown -R $USR /home/$USR/.vim/
cp -v ./molokai.vim /home/$USR/.vim/colors/
cp -v ./monokai.vim /home/$USR/.vim/colors/
cp -v ./.vimrc /home/$USR/

## bash
cp -v ./.bash_aliases /home/$USR/
cp -v ./.bash_greeting /home/$USR/
cp -v ./.bash_logout /home/$USR/
cp -v ./.bash_profile /home/$USR/
cp -v ./.bashrc /home/$USR/

## zsh
cp -v ./.zsh_aliases /home/$USR/
cp -v ./.zshrc /home/$USR/
cp -v ./ficus.zsh-theme /home/$USR/.oh-my-zsh/themes/

## gedit
mkdir -p /home/$USR/.local/share/gtksourceview-3.0/styles/ 
#chown -R $USR /home/$USR/.local/
cp -v monokai-extend.xml /home/$USR/.local/share/gtksourceview-3.0/styles/

## permissions cleanup
chown -R $USR:$USR /home/$USR

echo "Phase 4 Complete."
sleep 1
