#!/bin/bash

PM='apt'

# Function to prompt the user
prompt_user() {
    while true; do
        read -p "Is the package manager 'dnf' or 'apt'? [dnf/apt]: " user_choice

        case $user_choice in
            dnf)
                PM='dnf'
                break
                ;;
            apt)
                PM='apt'
                break
                ;;
            *)
                echo "Invalid choice. Please enter 'dnf' or 'apt'."
                ;;
        esac
    done
}

# Call the function to prompt the user
prompt_user

# Output the chosen package manager
echo "Package manager set to: $PM"

sudo $PM update -y

sudo $PM install git -y

if [[ -f $HOME/.ssh/id_rsa.pub ]]; then
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

# Update and upgrade
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

# Install Thorium
if [ "$PM" == "apt" ]; then
	sudo rm -fv /etc/apt/sources.list.d/thorium.list
	sudo wget --no-hsts -P /etc/apt/sources.list.d/ http://dl.thorium.rocks/debian/dists/stable/thorium.list
	sudo apt update -y
fi

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

# Neovim
rm $HOME/.config/nvim
sudo $PM install -y nvim
cd $HOME/.config
git clone git@github.com:helauren42/neovimConfig.git nvim

# Docker
install_docker_apt() {
	if [ "$PM" == "apt" ]; then
		sudo apt update
		sudo apt install -y ca-certificates curl gnupg
		sudo mkdir -p /etc/apt/keyrings
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
		echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
		sudo apt update
		sudo apt install -y docker-ce docker-ce-cli containerd.io
	fi
}

install_docker_dnf() {
	if [ "$PM" == "dnf" ]; then
		sudo dnf -y install dnf-plugins-core
		sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
		sudo dnf install -y docker-ce docker-ce-cli containerd.io
	fi
}

install_docker_compose() {
	sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
}

configure_user() {
	sudo groupadd docker 2>/dev/null || true
	sudo usermod -aG docker $USER
	echo "User $USER added to docker group. Log out and back in to apply changes."
}

case $PM in
"apt")
	echo "Using apt to install Docker..."
	install_docker_apt
	;;
"dnf")
	echo "Using dnf to install Docker..."
	install_docker_dnf
	;;
*)
	exit 1
	;;
esac

install_docker_compose
configure_user

docker --version
docker-compose --version

echo "Setup complete!"
