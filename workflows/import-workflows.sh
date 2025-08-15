#!/bin/bash
set -e

N8N_USER=${N8N_USER:-admin}
N8N_PASS=${N8N_PASS:-changeme}
N8N_HOST=${N8N_HOST:-http://localhost:5678}

WORKFLOWS_FILE="workflows-export/workflows.json"
jq empty "$WORKFLOWS_FILE"  # Validar JSON

jq -c '.[]' "$WORKFLOWS_FILE" | while read -r wf; do
  curl -s -u "$N8N_USER:$N8N_PASS" \
       -H "Content-Type: application/json" \
       -X POST \
       --data "$wf" \
       "$N8N_HOST/rest/workflows"
done