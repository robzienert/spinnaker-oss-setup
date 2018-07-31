source /tmp/spinnaker-setup.sh

function setup_repo() {
  local project="$1"
  local github_upstream="$2"
  if [[ -z "$2" ]]; then
    github_upstream="spinnaker"
  fi

  ok github $SPINNAKER_WORKSPACE/$project $github_upstream/$project
  if did_update; then
    cd $SPINNAKER_WORKSPACE/$project
    echo "Setting upstream remote"
    git remote rename origin upstream
    git remote add origin git@github.com:$GITHUB_USERNAME/$project.git
    git branch --set-upstream-to upstream/master
  fi
}

ok directory $SPINNAKER_WORKSPACE

setup_repo "clouddriver"
setup_repo "deck"
setup_repo "echo"
setup_repo "fiat"
setup_repo "front50"
setup_repo "gate"
setup_repo "halyard"
setup_repo "keiko"
setup_repo "igor"
setup_repo "kayenta"
setup_repo "keel"
setup_repo "kork"
setup_repo "moniker"
setup_repo "orca"
setup_repo "rosco"
setup_repo "scheduled-actions"
setup_repo "swabbie"
setup_repo "spinnaker-dependencies"
setup_repo "spinnaker-gradle-project"
setup_repo "spinnaker-performance" "ajordens"
setup_repo "styleguide"

# TODO rz - spincli needed as well
