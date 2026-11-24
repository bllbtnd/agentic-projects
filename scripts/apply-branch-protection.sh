#!/usr/bin/env bash
# The owner command is scripts/apply-repo-setup.sh. This name still works.
exec "$(cd "$(dirname "$0")" && pwd)/apply-repo-setup.sh" "$@"
