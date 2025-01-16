# AWS SecretsManager to BazelRC file Buildkite Plugin [![Build status](https://badge.buildkite.com/d673030645c7f3e7e397affddd97cfe9f93a40547ed17b6dc5.svg)](https://buildkite.com/buildkite/aws-secretsmanager-to-bazelrc)

A Buildkite plugin that will take a JSON blob from an AWS SecretsManager path and hydrate it into Bazel configuration options.

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
    command: "bazelisk build --config=buildkite --bazelrc=.bazelrc --bazelrc=.bazelrc-generated //..."
    plugins:
      - aws-secretsmanager-to-bazelrc-file#v1.0.0:
          path: "my/secret/path"
```

## And with other options as well

With all configuration options included.

```yaml
steps:
  - label: "🔨 Running plugin"
    command: "bazelisk build --config=bk --bazelrc=.bazelrc --bazelrc=other //..."
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
    command: "bazelisk build --config=bk --bazelrc=.bazelrc --bazelrc=other //..."
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

## 📜 License

The package is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
