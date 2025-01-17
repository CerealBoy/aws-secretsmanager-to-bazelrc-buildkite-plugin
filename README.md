# AWS SecretsManager to BazelRC file Buildkite Plugin [![Build status](https://badge.buildkite.com/d673030645c7f3e7e397affddd97cfe9f93a40547ed17b6dc5.svg)](https://buildkite.com/buildkite/aws-secretsmanager-to-bazelrc)

A Buildkite plugin that will take a JSON blob from an AWS SecretsManager path and hydrate it into Bazel configuration options.

## Secret data structure

The secret stored within AWS SecretsManager is expected to be a JSON object that conforms to a specific structure.

```json
{
  "files": [
    {
      "filename": "file-to-output-content.extension",
      "key": "key_used_in_bazelrc_file",
      "value": "super-secret-content"
    }
  ],
  "values": [
    {
      "key": "key_used_in_bazelrc_file",
      "value": "secret-content-of-key"
    }
  ]
}
```

There are 2 lists that will be used, with slightly different uses.

1. `files` contains a list of objects that will hydrate files into a temporary path and reference those files.
    1. `filename` is the name of the file to place the content.
    1. `key` is the argument the file will be referenced to within the `.bazelrc` configuration.
    1. `value` is the base64-encoded file content.
1. `values` are bare values that will be placed into the `.bazelrc` file.
    1. `key` is the argument for the value.
    1. `value` is the bare value to be placed into the config.

All `files` will be placed into a generated temporary path, this matches the pattern `aws-secretsmanager-bazelrc-tmp.XXXXXX`. The included `post-command` hook will remove this path after the command is completed to prevent these secret files from being left-behind.

## Options

These are all the options available to configure this plugin's behaviour.

### Required

#### `path` (string)

The path within SecretsManager that the secret can be retrieved from.

### Optional

#### `bazel-config` (string)

The name of the config group within Bazel to assign the parameters to. This is the value that will be used in the `--config=` switch when running Bazel.

By default, this value is set to `buildkite`.

#### `output-filename` (string)

The filename of the generated `.bazelrc` configuration. This is the filename that will be referred to when using `--bazelrc=` when running Bazel.

By default, this value is set to `.bazelrc-buildkite`.

## Examples

Default usage.

```yaml
steps:
  - label: "🔨 Running plugin"
    command: "bazelisk --bazelrc=.bazelrc --bazelrc=.bazelrc-generated build --config=buildkite //..."
    plugins:
      - aws-secretsmanager-to-bazelrc-file#v1.0.0:
          path: "my/secret/path"
```

## And with other options as well

With all configuration options included.

```yaml
steps:
  - label: "🔨 Running plugin"
    command: "bazelisk --bazelrc=.bazelrc --bazelrc=other build --config=bk //..."
    plugins:
      - aws-secretsmanager-to-bazelrc-file#v1.0.0:
          path: "my/secret/path"
          bazel-config: "bk"
          output-filename: "other"
```

## Combining with other plugins

This plugin is designed to work with the [aws-assume-role-with-web-identity](https://github.com/buildkite-plugins/aws-assume-role-with-web-identity-buildkite-plugin) plugin to allow for OIDC access to SecretsManager.

See the [Buildkite docs](https://buildkite.com/docs/pipelines/security/oidc/aws) for a comprehensive guide on setting up and using OIDC.

```yaml
steps:
  - label: "🔨 Running plugin"
    command: "bazelisk --bazelrc=.bazelrc --bazelrc=other build --config=bk //..."
    plugins:
      - aws-assume-role-with-web-identity#v1.1.0:
          role: "arn:aws:..."
      - aws-secretsmanager-to-bazelrc-file#v1.0.0:
          path: "my/secret/path"
          bazel-config: "bk"
          output-filename: "other"
```

## 👩‍💻 Contributing

Naturally, PRs are welcomed! The intention here is to ensure a JSON structure of secret content can be safely converted into configuration that allows for proper extended usage of Bazel, especially with services such as remote executors or caches.

### Using dry-run mode

To enable dry-run, use `DRY_RUN=1` to run the `hooks/pre-command` file. This will allow for the subsequent use of `DRY_RUN_FILE` that should reference a JSON file to simulate the content retrieved from AWS. A full example command might look like the following.

```bash
DRY_RUN=1 DRY_RUN_FILE=secretsmanager.json BUILDKITE_PLUGIN_AWS_SECRETSMANAGER_TO_BAZELRC_PATH=/unused ./hooks/pre-command
```

## 📜 License

The package is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
