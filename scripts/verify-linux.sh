#!/usr/bin/env bash

set -euo pipefail

scriptDirectory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repositoryRoot="$(cd -- "${scriptDirectory}/.." && pwd)"
buildDirectory="${AIMCPP_BUILD_DIRECTORY:-${repositoryRoot}/build/linux-gcc-debug}"
compilerExecutable="${CXX:-g++}"

if [[ -n "${AIMCPP_CMAKE:-}" ]]; then
    cmakeExecutable="${AIMCPP_CMAKE}"
elif [[ -x "${repositoryRoot}/.tools/cmake/bin/cmake" ]]; then
    cmakeExecutable="${repositoryRoot}/.tools/cmake/bin/cmake"
else
    cmakeExecutable="$(command -v cmake)"
fi

ctestExecutable="$(dirname -- "${cmakeExecutable}")/ctest"

if [[ ! -x "${ctestExecutable}" ]]; then
    ctestExecutable="$(command -v ctest)"
fi

"${cmakeExecutable}" --version
"${compilerExecutable}" --version
ninja --version

"${cmakeExecutable}" \
    -S "${repositoryRoot}" \
    -B "${buildDirectory}" \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_CXX_COMPILER="${compilerExecutable}"

"${cmakeExecutable}" --build "${buildDirectory}" --parallel

"${ctestExecutable}" \
    --test-dir "${buildDirectory}" \
    --output-on-failure \
    --no-tests=error
