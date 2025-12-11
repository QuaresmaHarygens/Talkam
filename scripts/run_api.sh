#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."/backend
if [ ! -d .venv ]; then
  python3 -m venv .venv
fi
source .venv/bin/activate
pip install --upgrade pip >/dev/null
pip install . >/dev/null
export PATH="/usr/local/opt/postgresql@15/bin:$PATH"
uvicorn app.main:app --reload
