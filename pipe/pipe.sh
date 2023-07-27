#!/usr/bin/env bash
source "$(dirname $0)/common.sh"
info "Starting Pipe ..."

# default vars
info "Getting vars ..."
PLAYBOOK_NAME=${PLAYBOOK_NAME:="playbook.yml"}
INVENTORY=${INVENTORY:="inventory"}
TAG=${TAG:=""}
VAULT_PASSPHRASE=${VAULT_PASSPHRASE:=""}
SSH_KEY_LOCATION=${SSH_KEY_LOCATION:=""}

# get playbook
info "Getting playbook ..."
PLAYBOOK_FILE=$(find -P / -name ${PLAYBOOK_NAME} -not -path /usr/lib/* 2> /dev/null)
PLAYBOOK_LOCATION=$(echo $PLAYBOOOK_FILE | sed 's/playbook.yml//')
info "found playbook at $PLAYBOOK_LOCATION"
cd $PLAYBOOK_LOCATION

# create ansible command
info "creating ansible command ..."
ANSIBLE_COMMAND="ansible-playbook $PLAYBOOK_NAME -i inventory"

if [$TAG != ""]; then
  info "Add tag ..."  
  ANSIBLE_COMMAND=$ANSIBLE_COMMAND+" -t $TAG"
  info "done"
fi

if [$VAULT_PASSPHRASE != ""]; then
  info "add vault file ..."
  echo $VAULT_PASSPHRASE > vault_file
  ANSIBLE_COMMAND="$ANSIBLE_COMMAND--vault-pass-file vault_file"
  info "done"
fi

if [$SSH_KEY_LOCATION != ""]; then
  info "adding private key ..."
  ANSIBLE_COMMAND="$ANSIBLE_COMMAND --key-file $SSH_KEY_LOCATION"
  info "done"
fi


info "attempting ansible command ..."
info "$ANSIBLE_COMMAND"

bash -c "$ANSIBLE_COMMAND"

if [[ "${status}" == "0" ]]; then
  success "Success!"
else
  fail "Error!"
fi
