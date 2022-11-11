#!/usr/bin/env bash

set -euo pipefail

BASE_PATH="$(cd "$(dirname "$0")" && pwd)"
INPUT_PYRIGHT_VERSION=${INPUT_PYRIGHT_VERSION:-latest}

cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit 1

TEMP_PATH="$(mktemp -d)"
PATH="${TEMP_PATH}:$PATH"
export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

echo '::group::🐶 Installing reviewdog ... https://github.com/reviewdog/reviewdog'
curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1
echo '::endgroup::'

PYRIGHT_ARGS=(--outputjson)

if [ -n "${INPUT_PYTHON_PLATFORM:-}" ]; then
  PYRIGHT_ARGS+=(--pythonplatform "$INPUT_PYTHON_PLATFORM")
fi

if [ -n "${INPUT_PYTHON_VERSION:-}" ]; then
  PYRIGHT_ARGS+=(--pythonversion "$INPUT_PYTHON_VERSION")
fi

if [ -n "${INPUT_TYPESHED_PATH:-}" ]; then
  PYRIGHT_ARGS+=(--typeshed-path "$INPUT_TYPESHED_PATH")
fi

if [ -n "${INPUT_VENV_PATH:-}" ]; then
  PYRIGHT_ARGS+=(--venv-path "$INPUT_VENV_PATH")
fi

if [ -n "${INPUT_PROJECT:-}" ]; then
  PYRIGHT_ARGS+=(--project "$INPUT_PROJECT")
fi

if [ -n "${INPUT_LIB:-}" ]; then
  if [ "${INPUT_LIB^^}" != "FALSE" ]; then
    PYRIGHT_ARGS+=(--lib)
  fi
fi

cleanup() {
  if [ -n "${RDTMP:-}" ] && [ -d "${RDTMP:-}" ]; then
    rm -rf "$RDTMP"
  fi
}

echo '::group::🔎 Running pyright with reviewdog 🐶 ...'

RDTMP=$(mktemp -d)
trap cleanup EXIT

set -x

# shellcheck disable=SC2086
npm exec --yes -- "pyright@${INPUT_PYRIGHT_VERSION}" "${PYRIGHT_ARGS[@]}" ${INPUT_PYRIGHT_FLAGS:-} >"$RDTMP/pyright.json" || true

python3 "${BASE_PATH}/pyright_to_rdjson/pyright_to_rdjson.py" <"$RDTMP/pyright.json" >"$RDTMP/rdjson.json"

set +e
# shellcheck disable=SC2086
reviewdog -f=rdjson \
  -name="${INPUT_TOOL_NAME}" \
  -reporter="${INPUT_REPORTER:-github-pr-review}" \
  -filter-mode="${INPUT_FILTER_MODE}" \
  -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
  -level="${INPUT_LEVEL}" \
  ${INPUT_REVIEWDOG_FLAGS} < "$RDTMP/rdjson.json"

reviewdog_rc=$?

set +x
echo "reviewdog exited with exit status $reviewdog_rc"
echo '::endgroup::'

exit $reviewdog_rc
