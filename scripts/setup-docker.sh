#!/bin/bash

# this din't work on ICE VM running Ubuntu
# if (( $EUID != 0 )); then

# if [ "$EUID" -ne 0 ]; then
if [[ $(id -u) -ne 0 ]] ; then
    echo "Please run as root"
    echo 'This script runs a bunch of stuff as root in order to configure the environment'
    exit
fi

# Function to display commands
exe() { echo "\$ $@" ; "$@" ; }
say() { echo '#############'; echo "\$ $@" ; echo '#############';}

echo 'Gunnar är bäst!'
# set -x
say 'Updating package register'
exe apt-get update

say 'Remove any old docker stuff'
exe apt-get remove docker docker-engine docker.io containerd runc -y

say 'Install packages that allows apt to use a repo over https.'
exe apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y

say 'Fetch dockers official GPG key'
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

say 'set to STABLE repo'
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

say 'INSTALL DOCKER!!!'
exe apt-get update
exe apt-get install docker-ce docker-ce-cli containerd.io -y

say 'Make sure docker runs at startup'
exe systemctl start docker

say 'Verifying docker is installed'
exe docker --version

say 'Adding ubuntu to the docker user group'
exe usermod -a -G docker ubuntu

say 'Installing docker compose'
exe curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
say 'Giving docker compose permission to execute'
exe chmod +x /usr/local/bin/docker-compose

say 'Creating a directory for mounting docker persistent volumes'
exe mkdir ~/docker-persistence
say 'Give ownership to container user (UID 1001) and docker group'
exe chown 1001:docker ~/docker-persistence/
say 'Give read & write access to groups attached to folder'
exe chmod g+rw ~/docker-persistence



echo '-------------------------------'
echo '    '
echo 'NOW LOG OUT THE USER AND LOG IN AGAIN. OTHERWISE THE USER WILL NOT BE CONSIDERED PART OF THE DOCKER USER GROUP'
echo 'YOU MIGHT EVEN HAVE TO REBOOT THE SYSTEM FOR THE CHANGES TO TAKE EFFECT. if so, run "sudo reboot"'