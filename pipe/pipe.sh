#!/usr/bin/env bash
source "$(dirname $0)/common.sh"
info "Starting Pipe"

# default vars
PLAYBOOK_NAME=${PLAYBOOK_NAME:="playbook.yml"}
INVENTORY=${INVENTORY:="inventory"}
SSH_PRIVATE_KEY=${SSH_PRIVATE_KEY:=""}
TAG=${TAG:=""}
VAULT_PASSPHRASE=${VAULT_PASSPHRASE:=""}

# get playbook
PLAYBOOK_FILE=$(find -P / -name ${PLAYBOOK_NAME} -not -path /usr/lib/* 2> /dev/null)
PLAYBOOK_LOCATION=$(echo $PLAYBOOOK_FILE | sed 's/playbook.yml//')

info "ssh priv: $SSH_PRIVATE_KEY"
info "local: $(cat $SSH_PRIVATE_KEY)"

# goto playbook
cd $PLAYBOOK_LOCATION

# create ansible command
ANSIBLE_COMMAND="ansible-playbook $PLAYBOOK_NAME -i inventory"

if [$TAG != '']; then
  ANSIBLE_COMMAND=$ANSIBLE_COMMAND+" -t $TAG"
fi

if [$VAULT_PASSPHRASE != '']; then
  echo $VAULT_PASSPHRASE > vault_file
  ANSIBLE_COMMAND=$ANSIBLE_COMMAND+" --vault-pass-file vault_file"
fi

if [$SSH_PRIVATE_KEY != '']; then
  echo $SSH_PRIVATE_KEY > id_ssh
  ANSIBLE_COMMAND=$ANSIBLE_COMMAND+" --key-file id_ssh"
fi

bash -c "$ANSIBLE_COMMAND"

if [[ "${status}" == "0" ]]; then
  success "Success!"
else
  fail "Error!"
fi
