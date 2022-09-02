#!/bin/bash
readonly HERA_HOME=${HERA_HOME}
set -euo pipefail

# shellcheck source=library.sh
source "${HERA_HOME}"/library.sh

readonly CONTAINER_TO_DELETE=$(container_name "${JOB_NAME}" "${BUILD_ID}")
is_defined "${CONTAINER_TO_DELETE}" "Could not generate container name with provided JOB_NAME(${JOB_NAME}) and BUILD_ID(${BUILD_ID}."
if [[ "${CONTAINER_TO_DELETE}" == *"-slave-"* ]]; then
  echo "${CONTAINER_TO_DELETE} is a molecule slave running with systemd, so trying halt first:"
  run_ssh "podman exec ${CONTAINER_TO_DELETE} '/usr/sbin/halt'"
  sleep 2
fi
run_ssh "podman stop -i ${CONTAINER_TO_DELETE}"
