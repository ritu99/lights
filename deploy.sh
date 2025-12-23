#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Load environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Error: .env file not found"
    exit 1
fi

HA_HOST="${HA_HOST:-homeassistant.local}"
SSH_USER="${SSH_USER:-root}"
REMOTE_CONFIG="/homeassistant"

echo "==> Deploying config to $SSH_USER@$HA_HOST..."

# Upload YAML config files
echo "    Uploading YAML files..."
scp -q config/configuration.yaml "$SSH_USER@$HA_HOST:$REMOTE_CONFIG/"
scp -q config/automations.yaml "$SSH_USER@$HA_HOST:$REMOTE_CONFIG/"
scp -q config/scenes.yaml "$SSH_USER@$HA_HOST:$REMOTE_CONFIG/"
scp -q config/scripts.yaml "$SSH_USER@$HA_HOST:$REMOTE_CONFIG/"
scp -q config/secrets.yaml "$SSH_USER@$HA_HOST:$REMOTE_CONFIG/"

# Upload blueprints
echo "    Uploading blueprints..."
scp -rq config/blueprints "$SSH_USER@$HA_HOST:$REMOTE_CONFIG/"

# Upload zigbee2mqtt config (excluding logs and state)
echo "    Uploading zigbee2mqtt config..."
scp -q config/zigbee2mqtt/configuration.yaml "$SSH_USER@$HA_HOST:$REMOTE_CONFIG/zigbee2mqtt/" 2>/dev/null || true

echo "==> Validating configuration..."
VALIDATE_RESPONSE=$(curl -s -X POST \
    -H "Authorization: Bearer $HA_API_TOKEN" \
    -H "Content-Type: application/json" \
    "http://$HA_HOST:8123/api/config/core/check_config")

if echo "$VALIDATE_RESPONSE" | grep -q '"result":"valid"'; then
    echo "    Configuration is valid!"
else
    echo "    Configuration validation failed:"
    echo "$VALIDATE_RESPONSE"
    exit 1
fi

echo "==> Reloading Home Assistant..."

# Reload core configuration
curl -s -X POST \
    -H "Authorization: Bearer $HA_API_TOKEN" \
    -H "Content-Type: application/json" \
    "http://$HA_HOST:8123/api/services/homeassistant/reload_core_config" > /dev/null

# Reload automations
curl -s -X POST \
    -H "Authorization: Bearer $HA_API_TOKEN" \
    -H "Content-Type: application/json" \
    "http://$HA_HOST:8123/api/services/automation/reload" > /dev/null

# Reload scenes
curl -s -X POST \
    -H "Authorization: Bearer $HA_API_TOKEN" \
    -H "Content-Type: application/json" \
    "http://$HA_HOST:8123/api/services/scene/reload" > /dev/null

# Reload scripts
curl -s -X POST \
    -H "Authorization: Bearer $HA_API_TOKEN" \
    -H "Content-Type: application/json" \
    "http://$HA_HOST:8123/api/services/script/reload" > /dev/null

echo "==> Deploy complete!"
