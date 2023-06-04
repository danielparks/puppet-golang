#!/bin/bash

set -e

export UTIL_TRACE=1
source util.sh

puppet=puppet8
provider=docker

usage () {
  echo "Usage: $0 [OPTION [OPTION...]] COMMAND [COMMAND...]"
  echo ""
  echo "OPTION may by one of:"
  echo "  --docker      use docker for tests [default]"
  echo "  --vagrant     use vagrant for tests"
  echo "  --puppet7 -7  run tests in Puppet 7"
  echo "  --puppet8 -8  run tests in Puppet 8 [default]"
  echo ""
  echo "COMMAND may be one of:"
  echo "  init          initialize test set up"
  echo "  update        reinstall module"
  echo "  run           run tests"
  echo "  destroy       destroy virtual machines or docker images"
  echo ""
  echo "If vagrant is used, the following additional commands are supported:"
  echo "  snapshot      save a snapshot called 'general'"
  echo "  restore       restore a snapshot called 'general'"
  echo "  fast-init     restore to post-init state and reinstall the module"
  echo ""
  echo "Examples:"
  echo "  $0 init run destroy"
  echo "  $0 --vagrant -7 init run"
  echo "  $0 --vagrant -7 fast-init run"
}

init () {
  # FIXME sometimes we just want to ensure that things are set up, and not
  # actually recreate everything
  destroy

  rake "litmus:provision_list[${provider}]"

  if [[ $provider = vagrant ]] ; then
    # There’s a bug in Litmus that prevents Puppet from being updated when a
    # package is already available in the distro, e.g. on Ubuntu.
    bolt_task_run puppet_agent::install "collection=${puppet}" version=latest
    bolt_task_run provision::fix_secure_path path=/opt/puppetlabs/bin
    snapshot fresh
  else
    rake "litmus:install_agent[${puppet}]"
  fi

  rake litmus:install_module
}

snapshot () {
  local name=${1:-general}

  if [[ $provider != 'vagrant' ]] ; then
    echo 'snapshot command can only be used with vagrant.' >&2
    exit 1
  fi

  for box in .vagrant/*/Vagrantfile ; do
    (
      cd "$(dirname "$box")"
      vagrant snapshot save "$name"
    )
  done
}

restore () {
  local name=${1:-general}

  if [[ $provider != 'vagrant' ]] ; then
    echo 'restore command can only be used with vagrant.' >&2
    exit 1
  fi

  for box in .vagrant/*/Vagrantfile ; do
    (
      cd "$(dirname "$box")"
      vagrant snapshot restore "$name"
    )
  done
}

fast-init () {
  if [[ $provider != 'vagrant' ]] ; then
    echo 'fast-init command can only be used with vagrant.' >&2
    exit 1
  fi

  restore fresh
  rake litmus:install_module
}

update () {
  rake litmus:reinstall_module
}

run () {
  rake litmus:acceptance:parallel
}

destroy () {
  if [ -f spec/fixtures/litmus_inventory.yaml ] ; then
    # If there’s no inventory, there’s nothing to tear down.
    rake litmus:tear_down
    rm -f spec/fixtures/litmus_inventory.yaml
  fi
}

if [[ -z "$*" ]] ; then
  usage >&2
  exit 1
fi

for action in "$@" ; do
  case "$action" in
    --vagrant)
      provider=vagrant
      ;;
    --docker)
      provider=docker
      ;;
    -7|--puppet7)
      puppet=puppet7
      ;;
    -8|--puppet8)
      puppet=puppet8
      ;;
    --help)
      usage
      ;;
    init|snapshot|restore|fast-init|update|run|destroy)
      "$action"
      ;;
    *)
      usage >&2
      exit 1
      ;;
  esac
done
