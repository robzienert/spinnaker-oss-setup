#!/bin/bash

apt install -y build-essential
apt install -y libssl-dev
apt install -y gradle
apt install -y groovy
apt install -y nodejs
apt install -y redis
apt install -y mysql-server-5.7

# install nvm
mkdir -p $HOME/.nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
source ~/.bashrc

# Install yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
apt update
apt install -y --no-install-recommends yarn

# install zulu8 java
# see https://docs.azul.com/zulu/zuludocs/ZuluUserGuide/PrepareZuluPlatform/AttachAzulPackageRepositories.htm
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9
apt-add-repository 'deb http://repos.azulsystems.com/ubuntu stable main'
apt-get update
apt install zulu-8
