#!/bin/bash
set -euo pipefail

mkdir -p /logs/verifier

# Run plain pytest utilizing pre-baked image tools without additional install triggers
pytest /tests/test_outputs.py --json-ctrf=/logs/verifier/ctrf.json -rA || true

if [ -f /logs/verifier/ctrf.json ] && grep -q '"failed": 0' /logs/verifier/ctrf.json; then
  echo "1.0" > /logs/verifier/reward.txt
else
  echo "0.0" > /logs/verifier/reward.txt
fi