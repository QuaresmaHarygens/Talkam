#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
psql "postgres://talkam:talkam@localhost:5432/talkam" -f artifacts/data/schema.sql
