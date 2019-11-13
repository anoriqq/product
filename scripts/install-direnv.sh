#!/bin/bash

SCRIPTS_DIR=`cd $(dirname $0); pwd`
source ${SCRIPTS_DIR}/functions.sh



TASK_NAME='Installation of direnv'

log "[Start]: ${TASK_NAME}"

# Download of direnv binary to binary directory
BIN_DIR=${SCRIPTS_DIR}/bin
DIRENV_BIN_PATH=${BIN_DIR}/direnv
if [ ! -e "${DIRENV_BIN_PATH}" ]; then
  DIRENV_VERSION=2.20.0
  DIRENV_BIN_RELEASE=https://github.com/direnv/direnv/releases/download/v$DIRENV_VERSION/direnv.linux-amd64
  curl -L ${DIRENV_BIN_RELEASE} -o ${DIRENV_BIN_PATH}
  if [ $? -ne 0 ]; then exit 1; fi
  log "[Finish]: Download of direnv binary"
else
  log "[Skip]: Direnv binary already exists"
fi
chmod +x -R ${BIN_DIR}
if [ $? -ne 0 ]; then exit 1; fi

# Add direnv hook to shell
# @see https://github.com/direnv/direnv/blob/master/docs/hook.md
ZSHRC_PATH=~/.zshrc
if [ -e "${ZSHRC_PATH}" ]; then
  if grep -q 'eval $(direnv hook zsh)' ${ZSHRC_PATH}; then
    log "[Skip]: Zsh already has a Direnv hook"
  else
    echo -e '\n# direnv settings\neval $(direnv hook zsh)' >> ${ZSHRC_PATH}
    if [ $? -ne 0 ]; then exit 1; fi
    log "[Finish]: Add direnv hook to zsh"
  fi
else
  log "[Finish]: Add direnv hook to zsh"
fi
BASHRC_PATH=~/.bashrc
if [ -e "${BASHRC_PATH}" ]; then
  if grep -q 'eval $(direnv hook bash)' ${BASHRC_PATH}; then
    log "[Skip]: Bash already has a Direnv hook"
  else
    echo -e '\n# direnv settings\neval $(direnv hook bash)' >> ${BASHRC_PATH}
    if [ $? -ne 0 ]; then exit 1; fi
    log "[Finish]: Add direnv hook to bash"
  fi
else
  log "[Finish]: Add direnv hook to bash"
fi

# Add settings to .envrc file
ENVRC_PATH=./.envrc
ENVRC_SETTINGS='export PATH=$PATH:./scripts/bin\nexport WORKSPACE_ROOT=/home/anoriqq/workspace/product'
echo -e ${ENVRC_SETTINGS} >> ${ENVRC_PATH}
if [ $? -ne 0 ]; then exit 1; fi

# Activation direnv
direnv allow
if [ $? -ne 0 ]; then exit 1; fi

log "[Complete]: ${TASK_NAME}"
