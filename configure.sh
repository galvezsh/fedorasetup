#!/bin/bash

################################################
## VARIABLES ###################################
################################################

localThemeFolder="./themes"
localIconsFolder="./icons"

userThemeFolder="$HOME/.theme"
userIconsFolder="$HOME/.icons"

dnfConfigFile="/etc/dnf/dnf.conf"

option=0

################################################
## FUNCTIONS ###################################
################################################

function optimizeDNF() {

  echo "Optimizing the DNF system..."
  sudo cp "$dnfConfigFile" "${dnfConfigFile}.bak"
  sudo tee -a "$dnfConfigFile" > /dev/null <<EOF
# Better download speed by Alberto Galvez
fastestmirror=True
max_parallel_downloads=10
EOF

  sudo dnf clean all

  sudo dnf update -y
}

function removeApps() {
  
  echo "Removing unnecessary apps..."
  sudo dnf remove -y yelp totem snapshot gnome-clocks gnome-tour gnome-maps gnome-contacts libreoffice-writer libreoffice-impress libreoffice-calc rhythmbox evince simple-scan malcontent-control malcontent-pam malcontent-tools decibels showtime papers 
  sudo dnf autoremove -y

}

function installApps() {

  echo "Installing usefull apps..."
  sudo dnf install -y vlc obs-studio gnome-tweaks fastfetch btop htop

  sudo flatpak install -y flathub com.mattjakeman.ExtensionManager
  sudo flatpak install -y flathub io.github.realmazharhussain.GdmSettings
  sudo flatpak install -y flathub org.jellyfin.JellyfinDesktop
  sudo flatpak install -y flathub org.onlyoffice.desktopeditors

  read -p "Do you want to install some games? (y/n): " installGames
  if [ "$installGames" == "y" ]; then
    sudo flatpak install -y flathub org.prismlauncher.PrismLauncher
    sudo flatpak install -y flathub org.vinegarhq.Sober
    sudo dnf install -y steam
  fi

  read -p "Do you want to install Docker from the original repository? (y/n): " installDocker
  if [ "$installDocker" == "y" ]; then
    sudo dnf -y install dnf-plugins-core
    sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl start docker
  fi

  gsettings&

  gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
  gsettings set org.gnome.desktop.sound allow-volume-above-100-percent true

}

function installMediaCodecs() {

  echo "Installing media codecs..."
  sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
  sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
  sudo dnf install -y libavcodec-freeworld --allowerasing

  read -p "What graphics card do you have? Intel or AMD? (i/a): " graphicsCard
  case $graphicsCard in
    i)
      sudo dnf install -y intel-media-driver --allowerasing
      ;;
    a)
      sudo dnf install -y mesa-va-drivers-freeworld --allowerasing
      ;;
    *)
      echo "Invalid option, please select between Intel or AMD..."
      ;;
  esac
}

function customize() {

  echo "Installing some themes for GNOME..."
  if [ ! -d "$userThemeFolder" ]; then
    mkdir "$userThemeFolder"
  fi
  if [ ! -d "$userIconsFolder" ]; then
    mkdir "$userIconsFolder"
  fi

  # Themes
  if [ -d "$localThemeFolder" ]; then
    cp -r $localThemeFolder $userThemeFolder
  else
    echo "The themes folder doesn't exist. Skipping..."
  fi

  # Icons
  if [ -d "$localIconsFolder" ]; then
    cp -r $localIconsFolder $userIconsFolder
  else
    echo "The icons folder doesn't exist. Skipping..."
  fi
}

function fullCustomization() {

  optimizeDNF
  removeApps
  installApps
  installMediaCodecs
  customize

}

################################################
## SCRIPT ######################################
################################################

echo "#################################################"
echo "## Fedora Customizer, by Alberto Gálvez (v2.0) ##"
echo "#################################################"

if [ "$EUID" -ne 0 ]; then
  echo "This script needs administrative permissions. Launch this file with 'sudo'."
  exit 1
fi

while [[ "$option" -ne 6 ]]; do

  echo ""
  echo "Options: "
  echo "1. Full optimization"
  echo "2. Optimize DNF"
  echo "3. Remove usless apps"
  echo "4. Install useful apps"
  echo "5. Install media codecs"
  echo "6. Mount themes & icons"
  echo "7. Exit program"

  read -p "Select a option: " option

  case $option in
    1)
      echo "Building the new Fedora..."
      fullCustomization
      ;;
    2)
      optimizeDNF
      ;;
    3)
      removeApps
      ;;
    4)
      installApps
      ;;
    5)
      installMediaCodecs
      ;;
    6)
      customize
      ;;
    7)
      echo "Exiting program..."
      ;;
    *)
      echo "Invalid option, please select between 1 and 6..."
      ;;
  esac
done

exit 0