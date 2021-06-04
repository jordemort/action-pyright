# action-pyright

[![depup](https://github.com/jordemort/action-pyright/workflows/depup/badge.svg)](https://github.com/jordemort/action-pyright/actions?query=workflow%3Adepup)
[![release](https://github.com/jordemort/action-pyright/workflows/release/badge.svg)](https://github.com/jordemort/action-pyright/actions?query=workflow%3Arelease)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/jordemort/action-pyright?logo=github&sort=semver)](https://github.com/jordemort/action-pyright/releases)
[![action-bumpr supported](https://img.shields.io/badge/bumpr-supported-ff69b4?logo=github&link=https://github.com/haya14busa/action-bumpr)](https://github.com/haya14busa/action-bumpr)

This is an action that runs the [pyright](https://github.com/Microsoft/pyright) type checker against your Python code, and uses [reviewdog](https://github.com/reviewdog/reviewdog) to create GitHub PR comments or reviews with the results.

This action is based on [action-eslint](https://github.com/reviewdog/action-eslint) and inspired by [pyright-action](https://github.com/jakebailey/pyright-action).

You can configure pyright using [`pyrightconfig.json` or `pyproject.toml`](https://github.com/microsoft/pyright/blob/main/docs/configuration.md), or see the inputs below.

## Example usage

```yml
name: reviewdog
on: [pull_request]
jobs:
  pyright:
    name: pyright
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: jordemort/action-pyright@v1
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }} # You need this
          reporter: github-pr-review # Change reporter.
          lib: true
```

## Inputs

### `github_token`

**Required**. Default is `${{ github.token }}`.

### `level`

Optional. Report level for reviewdog [info,warning,error].
It's same as `-level` flag of reviewdog.

### `reporter`

Reporter of reviewdog command [github-pr-check,github-check,github-pr-review].
Default is github-pr-review.
It's same as `-reporter` flag of reviewdog.

github-pr-review can use Markdown and add a link to rule page in reviewdog reports.

### `filter_mode`

Optional. Filtering mode for the reviewdog command [added,diff_context,file,nofilter].
Default is added.

### `fail_on_error`

Optional. Exit code for reviewdog when errors are found [true,false]
Default is `false`.

### `reviewdog_flags`

Optional. Additional reviewdog flags

### `workdir`

Optional. The directory from which to look for and run eslint. Default '.'

### `pyright_version`

Optional. Version of pyright to run. If not specified, the latest version will be used.

### `python_platform`

Optional. Analyze for a specific platform (Darwin, Linux, Windows)

### `python_version`

Optional. Analyze for a specific Python version (3.3, 3.4, etc.)

### `typeshed_path`

Optional. Use typeshed type stubs at this location.

### `venv_path`

Optional. Directory that contains virtual environments.

### `project`

Optional. Use the configuration file at this location.

### `lib`

Optional. Use library code to infer types when stubs are missing. Default `false`.

### `pyright_flags`

Optional extra arguments; can be used to specify specific files to check.
