#!/bin/bash

PM=apt

# Keyboard repeat rate (X11)
xset r rate 230 30 || {
	echo "xset failed, trying gsettings for GNOME..."
	gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 33
	gsettings set org.gnome.desktop.peripherals.keyboard delay 230
}

# Install Thorium
sudo rm -fv /etc/apt/sources.list.d/thorium.list
sudo wget --no-hsts -P /etc/apt/sources.list.d/ http://dl.thorium.rocks/debian/dists/stable/thorium.list
sudo apt update -y

# MyShellEnv
cd $HOME
git clone https://github.com/helauren42/.MyShellEnv
echo "source $HOME/.MyShellEnv/update.sh" >>$HOME/.bashrc
source $HOME/.bashrc

# Install zsh and set as default shell
sudo $PM install -y zsh
chsh -s /bin/zsh

# Alacritty
sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt update
sudo apt install alacritty -y

# Neovim
rm $HOME/$USER/.config/nvim
sudo $PM install -y neovim
cd $HOME/.config
git clone git@github.com:helauren42/neovimConfig.git nvim

# Docker
install_docker_apt() {
	sudo apt update
	sudo apt install -y ca-certificates curl gnupg
	sudo mkdir -p /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
	sudo apt update
	sudo apt install -y docker-ce docker-ce-cli containerd.io
}

install_docker_dnf() {
	sudo dnf -y install dnf-plugins-core
	sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
	sudo dnf install -y docker-ce docker-ce-cli containerd.io
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
	echo "Unsupported package manager: $PM. Please use 'apt' or 'dnf'."
	exit 1
	;;
esac

install_docker_compose
configure_user

docker --version
docker-compose --version

echo "Setup complete!"
