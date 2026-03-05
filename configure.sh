#!/bin/bash

################################################
## VARIABLES ###################################
################################################

REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

localThemeFolder="./themes"
localIconsFolder="./icons"

userThemeFolder="$REAL_HOME/.themes"
userIconsFolder="$REAL_HOME/.icons"

dnfConfigFile="/etc/dnf/dnf.conf"
hostnameFile="/etc/hostname"

GRAAL_URL="https://download.oracle.com/graalvm/25/latest/graalvm-jdk-25_linux-x64_bin.tar.gz"

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
  sudo dnf install -y vlc obs-studio gnome-tweaks fastfetch btop htop intel-undervolt tlp

  sudo flatpak install -y flathub com.mattjakeman.ExtensionManager
  sudo flatpak install -y flathub io.github.realmazharhussain.GdmSettings
  sudo flatpak install -y flathub org.jellyfin.JellyfinDesktop
  sudo flatpak install -y flathub org.onlyoffice.desktopeditors

  read -p "Do you want to install some games? (y/n): " installGames
  if [[ "$installGames" =~ ^[Yy]$ ]]; then
    sudo flatpak install -y flathub org.prismlauncher.PrismLauncher
    sudo flatpak install -y flathub org.vinegarhq.Sober
    sudo dnf install -y steam
  fi

  read -p "Do you want to install Docker from the original repository? (y/n): " installDocker
  if [[ "$installDocker" =~ ^[Yy]$ ]]; then
    sudo dnf -y install dnf-plugins-core
    sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl start docker
  fi
}

function installCodecs() {

  echo "Installing media codecs..."
  sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
  sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
  sudo dnf install -y libavcodec-freeworld --allowerasing

  read -p "What graphics card do you have? Intel or AMD? (i/a): " graphicsCard
  case $graphicsCard in
    i)
      sudo dnf install -y intel-media-driver --allowerasing
      sudo dnf install -y intel-gpu-tools
      ;;
    a)
      sudo dnf install -y mesa-va-drivers-freeworld --allowerasing
      sudo dnf install -y radeontop
      ;;
    *)
      echo "Invalid option, please select between Intel or AMD..."
      ;;
  esac
}

function mountThemes() {

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

  echo "Configuring the new Fedora..."
  optimizeDNF
  removeApps
  installApps
  installCodecs
  mountThemes
}

function postCustomization() {

  echo "Tweaking the new Fedora..."
  gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
  gsettings set org.gnome.desktop.sound allow-volume-above-100-percent true

  # Settin up the variable enviorment
  echo "alias ll=\"ls -lhva\"" >> $REAL_HOME/.bashrc
  echo "alias stop=\"sudo btop\"" >> $REAL_HOME/.bashrc
  echo "alias rtop=\"sudo radeontop\"" >> $REAL_HOME/.bashrc
  echo "alias utop=\"sudo intel_gpu_top\"" >> $REAL_HOME/.bashrc
  echo "export JAVA_HOME=\"/opt/java\"" >> $REAL_HOME/.bashrc
  echo "export PATH=\"\$JAVA_HOME/bin:\$PATH\"" >> $REAL_HOME/.bashrc
  echo "fastfetch" >> $REAL_HOME/.bashrc

  # Installing Java 25
  wget -qO /tmp/graalvm.tar.gz "$GRAAL_URL"
  sudo tar -xzf /tmp/graalvm.tar.gz -C /opt
  sudo rm -rf /opt/java
  GRAAL_DIR=$(tar -tf /tmp/graalvm.tar.gz | head -1 | cut -f1 -d"/")
  sudo mv "/opt/$GRAAL_DIR" /opt/java
  rm /tmp/graalvm.tar.gz

  # Change the machine hostname
  read -p "Do you want to change the machine Hostname?: (y/n) " chHostname
  if [[ "$chHostname" =~ ^[Yy]$ ]]; then
    read -p "Insert the new hostname: " hostname
    sudo tee "$hostnameFile" > /dev/null <<EOF
    $hostname
EOF
  fi

  # Install the propiertary NVIDIA drivers
  read -p "¿Do you want to install the NVIDIA drivers for you graphics card? (y/n): " nvidiaDrivers
  if [[ "$nvidiaDrivers" =~ ^[Yy]$ ]]; then
    sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
    echo "Completed. You may have to WAIT FOR REBOOT your computer, around 3-5 minutes until the compilation completes."
  fi

  echo "Post configuration completed. Now i recommend some extensions for GNOME to improve the natural experiece of linux"
  echo ""
  echo "I recommend the follow extensions:"
  echo "=> User themes (gcampax) | Gives the capacity to change the themes and icons in gnome-tweaks"
  echo "=> Blur my shell (aunetx) | Does exacly what the name says"
  echo "=> Coverflow Alt-Tab (palatis) | A 3D carrusel for the Alt-Tab"
  echo "=> Desktop Cube (schneegans) | 3D effect when switching working spaces"
  echo "=> Clipboard Indicator (tudmotu) | Add a small clipboard indicator (for history) in the panel center"
  echo "=> Bluetooth Battery Meter (maniacx) | Add a detailed icon of the battery of the bluetooth device"
  echo "=> Caffeine (patapon) | Add a new button on the panel center for override the suspension and screensaver timer"
  echo "=> Vitals (CoreCoding) | Add a few icons in the top panel for the system status"
  echo "=> Weather O'Clock (CleoMenezesJr) | Add the weather in the center of the panel"
  echo "=> No overview at start-up (fthx) | Do what the name says"
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

while [ "$option" -ne 8 ]; do

  echo ""
  echo "Options: "
  echo "1. Full custumization"
  echo "2. Post customization script"
  echo ""
  echo "3. Optimize DNF"
  echo "4. Remove usless apps"
  echo "5. Install useful apps"
  echo "6. Install media codecs"
  echo "7. Mount themes & icons"
  echo "8. Exit program"

  read -p "Select a option: " option

  case $option in
    1)
      fullCustomization
      ;;
    2)
      postCustomization
      ;;
    3)
      optimizeDNF
      ;;
    4)
      removeApps
      ;;
    5)
      installApps
      ;;
    6)
      installCodecs
      ;;
    7)
      mountThemes
      ;;
    8)
      echo "Exiting program..."
      ;;
    *)
      echo "Invalid option, please select between 1 and 8..."
      ;;
  esac
done

exit 0