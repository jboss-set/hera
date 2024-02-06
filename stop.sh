#!/bin/bash
readonly HERA_HOME=${HERA_HOME}
readonly TIMEOUT_BEFORE_KILLING_CONTAINER=${TIMEOUT_BEFORE_KILLING_CONTAINER:-'15'}
set -euo pipefail

# shellcheck source=library.sh
source "${HERA_HOME}"/library.sh

readonly CONTAINER_TO_DELETE=$(container_name "${JOB_NAME}" "${BUILD_ID}")
is_defined "${CONTAINER_TO_DELETE}" "Could not generate container name with provided JOB_NAME(${JOB_NAME}) and BUILD_ID(${BUILD_ID}."
run_ssh "podman stop -t ${TIMEOUT_BEFORE_KILLING_CONTAINER} -i ${CONTAINER_TO_DELETE}"
