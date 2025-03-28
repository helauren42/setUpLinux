xset r rate 230 30

# install thorium
sudo rm -fv /etc/apt/sources.list.d/thorium.list &&
  sudo wget --no-hsts -P /etc/apt/sources.list.d/ \
    http://dl.thorium.rocks/debian/dists/stable/thorium.list &&
  sudo apt update -y

# MyShellEnv
cd $HOME
git clone https://github.com/helauren42/.MyShellEnv
source $HOME/.MyShellEnv/update.sh

chsh -s /bin/zsh

# Ghostty terminal
## install zig compiler
cd /opt
sudo tar xvf ~/Downloads/zig-linux-x86_64-0.13.0.tar.xz

wget https://github.com/ghostty-org/ghostty/archive/refs/tags/v2.1.3.tar.gz
tar xvf ~/Downloads/ghostty-2.1.3.tar.gz
cd ghostty-2.1.3

sudo $PM install libgtk-4-dev libadwaita-1-dev -y
sudo nice /opt/zig-linux-x87_64-0.13.0/zig build -p /usr/local -Doptimize=ReleaseFast

# Neovim

sudo $PM install neovim -y
cd $HOME/.config
git clone https://github.com/helauren42/neovimConfig nvim
