#!/usr/bin/env bash
set -euo pipefail

has_luacov() {
  command -v lua >/dev/null 2>&1 && command -v luacov >/dev/null 2>&1 &&
    lua -e 'assert(require("luacov.runner"))' >/dev/null 2>&1
}

if command -v busted >/dev/null 2>&1 && has_luacov; then
  echo 'Busted and LuaCov are already installed.'
  exit 0
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo 'Install Busted and LuaCov in the default WSL distribution, then run setup again.' >&2
  exit 1
fi

run_as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    echo 'Install Busted and LuaCov in WSL, or install sudo and run setup again.' >&2
    exit 1
  fi
}

echo 'Installing missing Lua test dependencies in WSL. sudo may ask for your password.'
run_as_root apt-get update
if ! command -v busted >/dev/null 2>&1; then
  run_as_root apt-get install -y lua-busted
fi
if ! has_luacov; then
  lua_version=$(lua -e 'print(_VERSION:match("%d+%.%d+"))')
  run_as_root apt-get install -y luarocks "liblua${lua_version}-dev"
  run_as_root luarocks --lua-version="$lua_version" install luacov
fi

if ! command -v busted >/dev/null 2>&1 || ! has_luacov; then
  echo 'Busted or LuaCov is unavailable. Check the WSL Lua installation.' >&2
  exit 1
fi

echo 'Busted and LuaCov are installed.'
