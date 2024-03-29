#!/usr/bin/env bash

PACKAGE_LIST=(
	vim
	calibre
	fish
	fira-code-fonts
	lutris
	steam
	vlc
	mcomix3
	htop
	gnome-boxes
	youtube-dl
	fastfetch
	pv
	wget
	java-latest-openjdk
	linux-util-user
	fwupd
 	android-tools
)

FLATPAK_LIST=(
	org.prismlauncher.PrismLauncher
	net.veloren.airshipper
)

# gnome settings

# enable rpmfusion
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -yq

sudo dnf groupupdate core -yq

# install development tools 
sudo dnf groupinstall "Development Tools" -yq
sudo rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg  -yq
printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg" |sudo tee -a /etc/yum.repos.d/vscodium.repo

# install multimedia packages
sudo dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -yq

sudo dnf groupupdate sound-and-video -yq

# fedora better fonts
sudo dnf copr enable dawid/better_fonts -yq
sudo dnf install fontconfig-enhanced-defaults fontconfig-font-replacements -yq

# add flathub repository
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# add brave browser for chromium testing pages
sudo dnf install dnf-plugins-core -yq
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install brave-browser -yq

# add third party software
 
# update repositories

sudo dnf check-update -yq

# iterate through packages and installs them if not already installed
for package_name in ${PACKAGE_LIST[@]}; do
	if ! sudo dnf list --installed | grep -q "^\<$package_name\>"; then
		echo "installing $package_name..."
		sleep .5
		sudo dnf install "$package_name" -y
		echo "$package_name installed"
	else
		echo "$package_name already installed"
	fi
done

for flatpak_name in ${FLATPAK_LIST[@]}; do
	if ! flatpak list | grep -q $flatpak_name; then
		flatpak install "$flatpak_name" -y
	else
		echo "$package_name already installed"
	fi
done


# add Mullvad
cd ..
cd Downloads
wget --content-disposition https://mullvad.net/download/app/rpm/latest
cd

# upgrade packages
sudo dnf distro-sync -y && sudo dnf update --refresh -y && sudo dnf update nobara-repos -y && flatpak update -y && flatpak remove --unused && sudo fwupdmgr get-updates
sudo dnf autoremove -yq

echo "************************************************"
echo "All good to go! Feel free to reboot your machine!"
echo "************************************************"
sleep 10
