#!/usr/bin/env bats

setup() {
  load "${BATS_PLUGIN_PATH}/load.bash"

  # Uncomment to enable stub debugging
  # export CURL_STUB_DEBUG=/dev/tty

  # you can set variables common to all tests here
  export DRY_RUN='1'
  export BUILDKITE_PLUGIN_AWS_SECRETSMANAGER_TO_BAZELRC_PATH='/my/path'
}

@test "Missing mandatory option fails" {
  unset BUILDKITE_PLUGIN_AWS_SECRETSMANAGER_TO_BAZELRC_PATH

  run "$PWD"/hooks/pre-command

  assert_failure
  assert_output --partial "Parameter 'path:' is required."
  refute_output --partial 'Running plugin'
}

@test "Normal basic operations" {
  run "$PWD"/hooks/pre-command

  assert_success
  assert_output --partial 'Running plugin with options'
  assert_output --partial ' path: /my/path'
  assert_output --partial ' bazel-config: buildkite'
  assert_output --partial ' output-filename: .bazelrc-buildkite'
}

@test "Optional value changes behaviour" {
  export BUILDKITE_PLUGIN_AWS_SECRETSMANAGER_TO_BAZELRC_BAZEL_CONFIG='bk'
  export BUILDKITE_PLUGIN_AWS_SECRETSMANAGER_TO_BAZELRC_OUTPUT_FILENAME='buildzelrc'

  run "$PWD"/hooks/pre-command

  assert_success
  assert_output --partial 'Running plugin with options'
  assert_output --partial ' path: /my/path'
  assert_output --partial ' bazel-config: bk'
  assert_output --partial ' output-filename: buildzelrc'
}
