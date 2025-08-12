# Fedora Setup Script

This script automates the installation and configuration of a Fedora-based system with essential utilities, developer tools, Docker, and custom tweaks.  
It is intended for **Fedora Workstation or Server** installations and should be run with **root privileges**.

---

## 📋 Features

- **System update and cleanup**
  - Updates all installed packages using `dnf`.
  - Removes unused dependencies.
  - Installs base tools such as `curl`, `wget`, `htop`, and more.

- **Developer tools installation**
  - Installs Git, GCC, and other build utilities.
  - Adds optional development libraries.

- **Docker installation**
  - Installs Docker Engine and related CLI tools from the official Fedora repositories or Docker's official repository.

- **Custom tweaks**
  - Adjusts system settings for better performance and usability.
  - Creates predefined user groups for access control.


## ⚠️ Requirements

- Fedora Workstation or Server.
- **Root privileges** (use `sudo` if running as a non-root user).
- Internet connection.

---

## 🚀 Quick Installation

You can run this script **directly from GitHub** without downloading it manually:

```bash
wget -O - https://raw.githubusercontent.com/galvezsh/fedorasetup/master/configure.sh | bash
```

---

## 📂 Step-by-step Actions

1. **Check root privileges**  
   The script ensures it is executed as root, otherwise it exits.

2. **Update and upgrade the system**  
   Uses `dnf upgrade --refresh` to fetch the latest updates.

3. **Install utilities**  
   Installs:
   - `curl`, `wget`
   - `htop`, `nano`, `vim`
   - Development tools via `dnf groupinstall "Development Tools"`

4. **Install Docker**  
   Configures Docker repository if necessary and installs:
   - `docker-ce`
   - `docker-ce-cli`
   - `containerd.io`

5. **Custom tweaks**  
   Creates custom user groups and adjusts system preferences.


## 📝 Notes

- The script may require you to log out and back in to apply some changes (especially for Docker group permissions).

---

## 📜 License

This script is provided **as-is** without warranty.  
You are free to modify and distribute it under your own terms.