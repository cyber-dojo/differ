#!/usr/bin/env bash
set -Eeu

repo_root()
{
  git rev-parse --show-toplevel
}
export -f repo_root

on_ci()
{
  [ -n "${CI:-}" ]
}
export -f on_ci
