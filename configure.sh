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
# Better download speed
fastestmirror=True
max_parallel_downloads=10
EOF

  sudo dnf clean all

  sudo dnf update -y
}

function removeApps() {
  
  echo "Removing unnecessary apps..."
  sudo dnf remove -y yelp totem snapshot gnome-clocks gnome-tour gnome-maps gnome-contacts libreoffice-writer libreoffice-impress libreoffice-calc rhythmbox evince simple-scan 
  sudo dnf autoremove -y

}

function installApps() {

  echo "Installing usefull apps..."
  sudo flatpak install -y flathub com.google.Chrome
  sudo flatpak install -y flathub com.visualstudio.code
  sudo flatpak install -y flathub com.mattjakeman.ExtensionManager

  sudo dnf install -y vlc obs-studio steam gnome-tweaks fastfetch htop

  gsettings&

  sudo dnf -y install dnf-plugins-core
  sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo systemctl start docker

  gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
  gsettings set org.gnome.desktop.sound allow-volume-above-100-percent true

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
  customize

}

################################################
## SCRIPT ######################################
################################################

echo "##########################################"
echo "## Fedora Customizer, by Alberto Gálvez ##"
echo "##########################################"

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
  echo "5. Mount themes & icons"
  echo "6. Exit program"

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
      customize
      ;;
    6)
      echo "Exiting program..."
      ;;
    *)
      echo "Invalid option, please select between 1 and 6..."
      ;;
  esac
done

exit 0