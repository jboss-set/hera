#!/bin/bash

readonly SCRIPT_NAME='run.sh'
source ./tests/tests-common.sh

setup() {
  export WORKSPACE=$(mktemp -d)
  # run tests within workspace
  cd "${WORKSPACE}"
}

teardown() {
  deleteIfExist "${WORKSPACE}"
}

@test "No JOB_NAME Defined" {
  run "${SCRIPT}"
  [ "${status}" -eq 3 ]
  [ "${lines[0]}" = 'No JOB_NAME provided.' ]
}

@test "No BUILD_ID Defined" {
  export JOB_NAME="test"
  run "${SCRIPT}"
  [ "${status}" -eq 4 ]
  [ "${lines[0]}" = 'No BUILD_ID provided.' ]
}

@test "Run in container" {
  export JOB_NAME="test"
  export BUILD_ID="1"
  run "${SCRIPT}"
  [ "${status}" -eq 0 ]
  echo "$output" | grep 'ssh -o StrictHostKeyChecking=no jenkins@podman.host podman run'
  echo "$output" | grep ' --userns=keep-id -u 1000:1000'
  echo "$output" | grep ' --name automaton-slave-test-1'
  echo "$output" | grep ' --add-host=olympus:10.88.0.1'
  echo "$output" | grep ' -v /home/jenkins//.ssh/:/var/jenkins_home/.ssh/:ro'
  echo "$output" | grep ' -v /home/jenkins//.gitconfig:/var/jenkins_home/.gitconfig:ro'
  echo "$output" | grep ' -v /home/jenkins//.netrc:/var/jenkins_home/.netrc:ro'
  echo "$output" | grep ' -d localhost/automatons'
}