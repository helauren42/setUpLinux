#!/bin/bash

PM='apt'

echo "Package manager set to: $PM"

sudo $PM update -y

sudo $PM install git -y

read -p "should a new ssh key be generated? " user_choice
if [[ "$answer" == 'y' && "$answer" == 'Y' ]]; then
	ssh-keygen
fi

echo "Add the following to your github ssh keys:"
cat $HOME/.ssh/id_rsa.pub
answer='n'
while [[ "$answer" != 'y' && "$answer" != 'Y' ]]; do
	echo "Have you added your public ssh key to github?(y/n) "
	read answer
done

sudo $PM update -y && sudo $PM upgrade -y

# Essential system utilities
sudo $PM install -y build-essential sudo curl wget htop tmux vim git ufw
# Networking & diagnostics
sudo $PM install -y net-tools iputils-ping traceroute dnsutils nmap
# Disk & filesystem management
sudo $PM install -y lsblk parted fdisk ntfs-3g rsync
# Security & access management
sudo $PM install -y fail2ban gnupg openssh-server
# Compression & archiving tools
sudo $PM install -y zip unzip tar gzip bzip2 xz-utils
# Other useful tools
sudo $PM install -y fzf ripgrep bat exa neofetch sudo apt zsh

sudo $PM install cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev -y

mkdir -p $USER/.config/nvim

# Keyboard repeat rate (X11)
xset r rate 230 30 || {
	echo "xset failed, trying gsettings for GNOME..."
	gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 33
	gsettings set org.gnome.desktop.peripherals.keyboard delay 230
}

# MyShellEnv
cd $HOME
git clone https://github.com/helauren42/.MyShellEnv
echo "source $HOME/.MyShellEnv/update.sh" >>$HOME/.bashrc
source $HOME/.bashrc

# Install zsh and set as default shell
sudo $PM install -y zsh
chsh -s /bin/zsh

# Alacritty
if [ "$PM" == "apt" ]; then
	sudo add-apt-repository ppa:neovim-ppa/stable
	sudo apt update
	sudo apt install alacritty -y
fi

sudo apt-get update

# Install required packages for HTTPS repositories
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Create directory for Docker GPG key
sudo mkdir -p /etc/apt/keyrings

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

# Update package index again
sudo apt-get update

# Install Docker Engine, CLI, and Containerd
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Start Docker service and enable it on boot
sudo systemctl start docker
sudo systemctl enable docker

# Add current user to docker group to run Docker without sudo (optional)
sudo usermod -aG docker $USER

# Verify Docker installation
docker --version

sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

docker --version
docker-compose --version

echo "Setup complete!"
