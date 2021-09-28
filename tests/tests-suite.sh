#!/bin/bash

dir_name="$(dirname "$0")"
work_dir="$(cd "${dir_name}/.." && pwd)"

runTests() {
  for tests in "${work_dir}"/tests/*.bats
  do
    local tests_file
    tests_file=$(basename "${tests}")
    if ! bats -t "${tests}" > "${work_dir}/tests/${tests_file%.bats}.tap"; then
      echo "${tests_file}"
    else
      rm "${work_dir}/tests/${tests_file%.bats}.tap"
    fi
  done
}

echo -n 'Run Tests...'
test_results=$(runTests)
if [ -n "${test_results}" ]; then
  for test_file in ${test_results}
  do
    echo -e "\nTest failures found in ${work_dir}/tests/${test_file}"
    cat "${work_dir}/tests/${test_file%.bats}.tap"
  done
  exit 1
fi
echo 'Done - PASSED'
echo ''


runShellCheck() {
  for script in "${work_dir}"/*.sh
  do
    if ! shellcheck "${script}" > "${script}.shellcheck"; then
      echo "${script}"
    else
      rm "${script}.shellcheck"
    fi
  done
}

echo -n 'Run Shellcheck on scripts...'
shellcheck_result=$(runShellCheck)
if [ -n "${shellcheck_result}" ]; then
  for script_file in ${shellcheck_result}
  do
    echo -e "\nShellCheck violations are found in ${script_file}"
    cat "${script_file}.shellcheck"
  done
  exit 1
fi
echo 'Done - PASSED'
