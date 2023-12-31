#!/usr/bin/env bash
source "$(dirname $0)/common.sh"
info "Starting Pipe ..."

# default vars + ssh
info "Getting ssh key and known hosts ... "
mkdir ~/.ssh
cp /opt/atlassian/pipelines/agent/ssh/id_rsa_tmp ~/.ssh/
cp /opt/atlassian/pipelines/agent/ssh/known_hosts ~/.ssh/
chmod 600 -R ~/.ssh

# non default vars
info "Getting vars ..."
VAULT_PASSPHRASE=${VAULT_PASSPHRASE:?'VAULT_PASSPHRASE variable missing.'}
PLAYBOOK_NAME=${PLAYBOOK_NAME:?'PLAYBOOK_NAME variable missing.'}
INVENTORY=${INVENTORY:?'INVENTORY variable missing.'}
TAG=${TAG:?'TAG variable missing.'}

# cd
info "Going to clone dir ..."
cd $BITBUCKET_CLONE_DIR
info "done":

# get playbook
info "Getting playbook ..."
info "$(find -P . -name ${PLAYBOOK_NAME} 2> /dev/null)"
PLAYBOOK_FILE=$(find -P . -name ${PLAYBOOK_NAME} 2> /dev/null)
info "$(echo ${PLAYBOOK_FILE} | sed "s/${PLAYBOOK_NAME}//")"
PLAYBOOK_LOCATION=$(echo ${PLAYBOOK_FILE} | sed "s/${PLAYBOOK_NAME}//")
info "found playbook at $PLAYBOOK_FILE, going to $PLAYBOOK_LOCATION"
cd $PLAYBOOK_LOCATION

# create ansible command
info "creating ansible command ..."
ANSIBLE_COMMAND="ansible-playbook $PLAYBOOK_NAME -i inventory"

if [ "$TAG" != "" ]; then
  info "Add tag ..."  
  ANSIBLE_COMMAND="$ANSIBLE_COMMAND -t $TAG"
  info "done"
fi

if [ "$VAULT_PASSPHRASE" != "" ]; then
  info "Add vault file ..."
  echo $VAULT_PASSPHRASE > vault_file
  ANSIBLE_COMMAND="$ANSIBLE_COMMAND --vault-pass-file vault_file"
  info "done"
fi

info "Adding private key ..."
ANSIBLE_COMMAND="$ANSIBLE_COMMAND --key-file ~/.ssh/id_rsa_tmp"
info "done"

info "attempting ansible command ..."
info "$ANSIBLE_COMMAND"

bash -c "$ANSIBLE_COMMAND"
success "Success!"
