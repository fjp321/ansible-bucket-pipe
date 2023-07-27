#!/usr/bin/env bash
source "$(dirname $0)/common.sh"
info "Starting Pipe"

INJECTED_SSH_CONFIG_DIR="/opt/atlassian/pipelines/agent/ssh"
# The default ssh key with open perms readable by alt uids
IDENTITY_FILE="${INJECTED_SSH_CONFIG_DIR}/id_rsa_tmp"
# The default known_hosts file
KNOWN_SERVERS_FILE="${INJECTED_SSH_CONFIG_DIR}/known_hosts"
mkdir -p ~/.ssh || debug "adding ssh keys to existing ~/.ssh"
touch ~/.ssh/authorized_keys
info "Using default ssh key"
cp ${IDENTITY_FILE} ~/.ssh/pipelines_id
if [ ! -f ${KNOWN_SERVERS_FILE} ]; then
  fail "No SSH known_hosts configured in Pipelines."
fi
cat ${KNOWN_SERVERS_FILE} >> ~/.ssh/known_hosts
if [ -f ~/.ssh/config ]; then
  debug "Appending to existing ~/.ssh/config file"
fi
echo "IdentityFile ~/.ssh/pipelines_id" >> ~/.ssh/config
chmod -R go-rwx ~/.ssh/

# default vars
PLAYBOOK_NAME=${PLAYBOOK_NAME:="playbook.yml"}
INVENTORY=${INVENTORY:="inventory"}
TAG=${TAG:=""}
VAULT_PASSPHRASE=${VAULT_PASSPHRASE:=""}

# get playbook
PLAYBOOK_FILE=$(find -P / -name ${PLAYBOOK_NAME} -not -path /usr/lib/* 2> /dev/null)
PLAYBOOK_LOCATION=$(echo $PLAYBOOOK_FILE | sed 's/playbook.yml//')

# goto playbook
cd $PLAYBOOK_LOCATION

# run ansible playbook
ANSIBLE_COMMAND="ansible-playbook $PLAYBOOK_NAME -i inventory"

if [$TAG != '']; then
  ANSIBLE_COMMAND=$ANSIBLE_COMMAND+" -t $TAG"
fi

if [$VAULT_PASSPHRASE != '']; then
  echo $VAULT_PASSPHRASE > vault_file
  ANSIBLE_COMMAND=$ANSIBLE_COMMAND+" --vault-pass-file vault_file"
fi

bash -c "$ANSIBLE_COMMAND"

if [[ "${status}" == "0" ]]; then
  success "Success!"
else
  fail "Error!"
fi
