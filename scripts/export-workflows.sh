#!/bin/bash
set -e

N8N_USER=${N8N_USER:-admin}
N8N_PASS=${N8N_PASS:-changeme}
N8N_HOST=${N8N_HOST:-http://localhost:5678}

EXPORT_DIR="workflows-export"
mkdir -p "$EXPORT_DIR"

curl -s -u "$N8N_USER:$N8N_PASS" "$N8N_HOST/rest/workflows" | jq . > "$EXPORT_DIR/workflows.json"