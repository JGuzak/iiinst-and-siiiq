#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
if ! command -v busted >/dev/null 2>&1; then
  echo 'Busted is required to run the tests. Install Busted and add it to PATH.' >&2
  exit 1
fi
if ! command -v luacov >/dev/null 2>&1 || ! lua -e 'assert(require("luacov.runner"))' >/dev/null 2>&1; then
  echo 'LuaCov is required for coverage. Install LuaCov for the Lua interpreter used by Busted.' >&2
  exit 1
fi
busted --coverage --recursive tests
luacov
echo 'Coverage report: luacov.report.out'
