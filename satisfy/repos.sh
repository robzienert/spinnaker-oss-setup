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
    hub fork --remote-name origin
  fi
}

ok directory $SPINNAKER_WORKSPACE

setup_repo "community"
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
setup_repo "swabbie"
setup_repo "spinnaker-gradle-project"
setup_repo "spinnaker-performance" "ajordens"
setup_repo "styleguide"
setup_repo "spinnaker.github.io"
setup_repo "spin"
