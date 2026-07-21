#!/usr/bin/env bash

set -euo pipefail

scriptDirectory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repositoryRoot="$(cd -- "${scriptDirectory}/.." && pwd)"
pythonExecutable="${PYTHON:-python3}"
toolDirectory="${AIMCPP_TOOL_DIRECTORY:-${repositoryRoot}/.tools/cmake}"

"${pythonExecutable}" -m venv "${toolDirectory}"
"${toolDirectory}/bin/python" -m pip install --upgrade "cmake==4.3.4"

"${toolDirectory}/bin/cmake" --version

printf 'CMake installed at: %s\n' "${toolDirectory}/bin/cmake"
printf 'Run: bash scripts/verify-linux.sh\n'
