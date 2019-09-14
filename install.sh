#!/bin/bash

# fail out on error
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"



function print_help {
  local current_install_dir=$(source $DIR/files/env.sh && echo $SPINNAKER_WORKSPACE)
  echo "usage: install.sh [-hu]"
  echo ""
  echo "-h         show help and exit"
  echo "-u         proceed with install without GITHUB_TOKEN"
  echo "             you will be prompted for github"
  echo "             credentials to create an oauth token"
  echo ""
  echo ""
  echo "Installs required system dependencies for Spinnaker development."
  echo "Sets up a development workspace in"
  echo "  $current_install_dir"
  echo ""
  echo "Edit $DIR/files/env.sh to customize workspace directory"
  exit 1
}

function validate_github {
  if [[ -z "${GITHUB_TOKEN}" && "$1" != "-u" ]]; then
    echo "GITHUB_TOKEN environment variable not set."
    echo "A Github oauth token with repo scope is required"
    echo "to use the github-cli (hub). Preferred is if"
    echo "you create this yourself:"
    echo ""
    echo "   https://github.com/settings/tokens "
    echo ""
    echo "You can proceed without a token, by supplying"
    echo "the -u flag, and a token will be created and"
    echo "saved  after you supply your github credentials"
    echo ""
    echo "see also:"
    echo " hub manpage (man hub)"
    echo ""
    print_help
  fi
}

case $(uname) in
  Darwin)
    OS="Darwin"
    ;;
  Linux)
    OS="Linux"
    ;;
  *)
    echo "Only supports OSX and Linux at this point (contribs welcome!)"
  echo ""
  echo ""
  print_help
esac

if [ "$1" == "-h" ]; then
  print_help
fi

validate_github $1

# install brew if not available
# skip for linux
if [ $OS = "Darwin" ]; then
  if ! type brew > /dev/null; then
    echo "Dependency not met: homebrew. Installing..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
fi

# install bork if not available (via brew for OSX,
# and via git clone for linux)
if ! type bork > /dev/null; then
  echo "Dependency not met: bork, installing..."
  case $OS in
    Darwin)
      brew install bork
      ;;
    Linux)
      git clone https://github.com/mattly/bork
      sudo ln -s $(pwd)/bork/bin/bork /usr/local/bin/bork
      ;;
    *)
      echo "Installing bork is not supported for your system (contrib. welcome!)"
      exit 1
  esac
fi

bork do ok symlink $HOME/.spinnaker-env.sh $DIR/files/env.sh
source $HOME/.spinnaker-env.sh

case $OS in
  Darwin)
    bork satisfy satisfy/taps.sh

    # need a JDK but can't bork cask this due to sudo
    brew cask install zulu8

    bork satisfy satisfy/osx.sh

    brew services start redis
    brew services start mysql@5.7

    export NVM_DIR="$HOME/.nvm"
    bork do ok directory $NVM_DIR
    source /usr/local/opt/nvm/nvm.sh
    ;;

  Linux)
    # use bash instead of bork
    sudo ./satisfy/linux.sh
    source $HOME/.nvm/nvm.sh
    ;;
  *)
    echo "Unsupported OS"
    exit 1
esac

bork satisfy satisfy/repos.sh
nvm install --lts
npm -g install yarn

bork do ok directory $HOME/.spinnaker
bork do ok symlink $HOME/.spinnaker/logback-defaults.xml $DIR/files/logback-defaults.xml

# don't fail on error
set +e

function update_shell_profile {
  local profile_file=$HOME/$1
  local expected_entry=$2

  grep -q "${expected_entry}" "${profile_file}" || echo "${expected_entry}" >> "${profile_file}"
}


read -d '' CONFIGURE_NVM <<'EOF'
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion" ] && . "/usr/local/opt/nvm/etc/bash_completion"  # This loads nvm bash_completion
EOF

SOURCE_SPINNAKER_ENV='source $HOME/.spinnaker-env.sh'
SOURCE_BASHRC='test -f $HOME/.bashrc && source $HOME/.bashrc'

if [[ "$SHELL" =~ ^.*bash$ ]]; then
  update_shell_profile ".bash_profile" "${SOURCE_SPINNAKER_ENV}"
  update_shell_profile ".bash_profile" "${SOURCE_BASHRC}"
  update_shell_profile ".bashrc" "${CONFIGURE_NVM}"
elif [[ "$SHELL" =~ ^.*zsh$ ]]; then
  update_shell_profile ".zshenv" "${SOURCE_SPINNAKER_ENV}"
  update_shell_profile ".zshrc" "${CONFIGURE_NVM}"
else
  echo "ACTIONS REQUIRED: "
  echo "Add to your shell environment:"
  echo "'${SOURCE_SPINNAKER_ENV}'"
  echo ""
  echo "Add to your shell rc:"
  echo "${CONFIGURE_NVM}"
  echo ""
fi

case $OS in
  Darwin)
    /usr/local/opt/mysql@5.7/bin/mysql -u root < $SPINNAKER_WORKSPACE/orca/orca-sql-mysql/mysql-setup.sql
    ;;
  Linux)
    sudo mysql < $SPINNAKER_WORKSPACE/orca/orca-sql-mysql/mysql-setup.sql
    ;;
  *)
  ;;
esac
if [ $? -ne 0 ]; then
  echo MySQL setup with $SPINNAKER_WORKSPACE/orca/orca-sql-mysql/mysql-setup.sql failed. Please check the status of the database and perform manual fixes as necessary.
  echo This execution is likely to fail if the orca database or orca_migrate and orca_service users already exist.
else
  echo spinnaker-oss-setup complete!
fi
