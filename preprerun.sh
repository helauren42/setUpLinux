#!/bin/bash

PM="apt"

sudo $PM update -y

sudo $PM install git -y

ssh-keygen

echo "Add the following to your github ssh keys:"
cat $HOME/.ssh/id_rsa.pub

answer='n'
while [[ "$answer" != 'y' && "$answer" != 'Y' ]]; do
  echo "Have you added your public ssh key to github?(y/n) "
  read answer
done

git clone https://github.com/helauren42/setUpLinux/

cd setUpLinux
chmod u+x *
./prerun.sh
./run.sh
