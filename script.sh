#!/usr/bin/env bash

set -euo pipefail

BASE_PATH="$(cd "$(dirname "$0")" && pwd)"

cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit 1

TEMP_PATH="$(mktemp -d)"
PATH="${TEMP_PATH}:$PATH"
export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

echo '::group::🐶 Installing reviewdog ... https://github.com/reviewdog/reviewdog'
curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1
echo '::endgroup::'

echo '::group::🐍 Installing pyright ...'
if [ -z "${INPUT_PYRIGHT_VERSION:-}" ]; then
  npm install pyright
else
  npm install "pyright@${INPUT_PYRIGHT_VERSION}"
fi
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

echo '::group::🔎 Running pyright with reviewdog 🐶 ...'
# shellcheck disable=SC2086
"$(npm bin)/pyright" "${PYRIGHT_ARGS[@]}" ${INPUT_PYRIGHT_FLAGS:-} | tee /tmp/pyright.json
  python3 "${BASE_PATH}/pyright_to_rdjson/pyright_to_rdjson.py" | tee /tmp/rdjson.json
  reviewdog -f=rdjson \
    -name="${INPUT_TOOL_NAME}" \
    -reporter="${INPUT_REPORTER:-github-pr-review}" \
    -filter-mode="${INPUT_FILTER_MODE}" \
    -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
    -level="${INPUT_LEVEL}" \
    ${INPUT_REVIEWDOG_FLAGS} < /tmp/rdjson.json

reviewdog_rc=$?
echo '::endgroup::'
exit $reviewdog_rc
