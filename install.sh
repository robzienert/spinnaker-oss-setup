#!/bin/bash
if [ "$#" -eq 0 ]; then
  echo "usage: install.sh <github_username>"
  echo
  echo "github_username   Your Github username"
  exit 1
fi

if [[ `uname` -ne "Darwin" ]]; then
  echo "Only supports OSX at this point (contribs welcome!)"
  exit 1
fi

if ! type brew > /dev/null; then
  echo "Dependency not met: homebrew. Installing..."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

if ! type bork > /dev/null; then
  echo "Dependency not met: bork, installing..."
  brew install bork
fi

echo "export GITHUB_USERNAME=$1" | tee /tmp/spinnaker-setup.sh
source /tmp/spinnaker-setup.sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

bork do ok symlink $HOME/.spinnaker-env.sh $DIR/files/env.sh
source $HOME/.spinnaker-env.sh

bork satisfy satisfy/osx.sh
bork satisfy satisfy/repos.sh

bork do ok directory $HOME/.spinnaker
bork do ok symlink $HOME/.spinnaker/logback-defaults.xml $DIR/files/logback-defaults.xml


if [ "$SHELL" = "/bin/bash" ]; then
  printf '\nsource $HOME/.spinnaker-env.sh' >> $HOME/.bash_profile
else
  echo "ACTION REQUIRED: Add 'source $HOME/.spinnaker-env.sh' to your shell"
fi

/usr/local/opt/mysql@5.7/bin/mysql -u root < ./files/mysql-setup.sql

