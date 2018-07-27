#!/bin/bash -e
if [ "$#" -eq 0 ]; then
  echo "usage: install.sh <github_username>"
  echo
  echo "github_username   Your Github username"
  exit 1
fi

echo "export GITHUB_USERNAME=$1" | tee /tmp/spinnaker-setup.sh
source /tmp/spinnaker-setup.sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

if [[ `uname` -ne "Darwin" ]]; then
  echo "Only supports OSX at this point (contribs welcome!)"
  exit 1
fi

bork do ok symlink $HOME/.spinnaker-env.sh $DIR/files/env.sh
source $HOME/.spinnaker-env.sh

bork satisfy satisfy/osx.sh
bork satisfy satisfy/repos.sh

bork do ok directory $HOME/.spinnaker
bork do ok symlink $HOME/.spinnaker/logback-defaults.xml $DIR/files/logback-defaults.xml

# TODO rz - should be automatic
echo "Add 'source $HOME/.spinnaker-env.sh' to your shell"
