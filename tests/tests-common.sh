#!/bin/bash

debugBatsTest() {

  for i in "${!lines[@]}"
  do
    echo "${lines[${i}]}"
  done
  echo "${status}"
}

deleteIfExist() {
  local file=${1}

  if [ -n "${file}" -a -e "${file}" ]; then
    rm -rf "${file}"
  fi
}

setupDummyCommandHomeDir() {

  readonly DUMMY_COMMAND_DIR=${DUMMY_COMMAND_DIR:-$(mktemp -d)}
  export DUMMY_COMMAND_DIR
  trap 'deleteIfExist ${DUMMY_COMMAND_DIR}' EXIT
  export PATH="${DUMMY_COMMAND_DIR}":"${PATH}"

}

setupDummySSH() {
  export DUMMY_SSH=${DUMMY_SSH:-"$(pwd)/tests/"}
  export PATH="${DUMMY_SSH}":"${PATH}"
}

createDummyCommand() {
  local command=${1}

  if [ -z "${command}" ]; then
    echo "No command provided - abort."
    exit 1
  fi
  local path_to_command="${DUMMY_COMMAND_DIR}/${command}"

  echo "echo ${command} \${@}" > "${path_to_command}"
  chmod +x "${path_to_command}"
  trap 'deleteIfExist ${path_to_command}' EXIT
}

createDummyBackgroundCommand() {
  createDummyCommand ${@}

  local path_to_command="${DUMMY_COMMAND_DIR}/${1}"
  # simple sleep 20 waits until end of sleep before being killed
  echo 'for i in {1...20}; do sleep 1; done' >> "${path_to_command}"
  echo 'echo done' >> "${path_to_command}"

}

setupDummyCommandHomeDir
setupDummySSH

if [ -z "${SCRIPT_NAME}" ]; then
  echo "No script name provided."
  exit 1
fi


readonly SCRIPT_HOME=${SCRIPT_HOME:-$(pwd)}
export HERA_HOME=${SCRIPT_HOME}
readonly SCRIPT="${SCRIPT_HOME}/${SCRIPT_NAME}"

if [ ! -d "${SCRIPT_HOME}" ]; then
  echo "Invalid home for ${SCRIPT_NAME}: ${SCRIPT_HOME}."
  exit 2
fi

if [ ! -e "${SCRIPT}" ]; then
  echo "Invalid path to script: ${SCRIPT}."
  exit 3
fi
