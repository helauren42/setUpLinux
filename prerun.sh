#!/bin/bash

PM="apt"

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
sudo $PM install -y fzf ripgrep bat exa neofetch

mkdir -p $USER/.config/nvim
