#!/bin/bash

# This script will be available in the container's PATH as 'config'
# It interacts with the Vercel backend to push and pull configurations.

set -e

VERCEL_DOMAIN="$VERCEL_DOMAIN"
if [ -z "$VERCEL_DOMAIN" ]; then
    echo "Error: VERCEL_DOMAIN environment variable is not set."
    exit 1
fi

API_URL="https://$VERCEL_DOMAIN/api/config"
CONFIG_FILES_DIR="/home/admin/config_files"

# Ensure the directory for config files exists
mkdir -p "$CONFIG_FILES_DIR"
chown -R admin:admin /home/admin

function usage() {
    echo "Usage: config <command> [user_id]"
    echo "Commands:"
    echo "  push <user_id>      - Push local configuration to the server."
    echo "  pull <user_id>      - Pull remote configuration and apply it."
    echo "  create <user_id>    - Create a new, empty configuration on the server."
}

function push_config() {
    local user_id=$1
    echo "Gathering installed packages..."
    # Get a list of manually installed packages on Debian
    local packages=$(apt-mark showmanual)

    echo "Gathering files from $CONFIG_FILES_DIR..."
    local files_json="{"
    for file in $(find $CONFIG_FILES_DIR -type f); do
        local filename=$(basename "$file")
        # Base64 encode the file content to handle special characters in JSON
        local content=$(base64 -w 0 "$file")
        files_json+="\"$filename\":\"$content\","
    done
    # Remove trailing comma
    files_json=$(echo "$files_json" | sed 's/,$//')
    files_json+="}"

    local payload=$(jq -n \
                  --arg packages "$packages" \
                  --argjson files "$files_json" \
                  '{packages: ($packages | split("\n") | map(select(. != ""))), files: $files}')

    echo "Pushing configuration for user: $user_id"
    curl -s -X POST -H "Content-Type: application/json" \
         -d "$payload" \
         "$API_URL/$user_id"
    echo -e "\nDone."
}

function pull_config() {
    local user_id=$1
    echo "Pulling configuration for user: $user_id"
    
    local response=$(curl -s -w "%{http_code}" "$API_URL/$user_id")
    local http_code=${response: -3}
    local body=${response::-3}

    if [ "$http_code" != "200" ]; then
        echo "Error: Failed to pull config. Server responded with status $http_code."
        echo "Response: $body"
        return 1
    fi

    echo "Applying configuration..."

    # Install packages
    local packages=$(echo "$body" | jq -r '.packages[]')
    if [ -n "$packages" ]; then
        echo "Installing packages: $packages"
        apt-get update > /dev/null
        # The tr removes trailing carriage returns if any
        apt-get install -y $(echo "$packages" | tr -d '\r') > /dev/null
    fi

    # Recreate files
    echo "Creating files in $CONFIG_FILES_DIR..."
    echo "$body" | jq -r '.files | to_entries[] | "\(.key) \(.value)"' |
    while read -r filename content;
    do
        local file_path="$CONFIG_FILES_DIR/$filename"
        echo "  -> Creating $file_path"
        # Decode the base64 content
        echo "$content" | base64 -d > "$file_path"
        chown admin:admin "$file_path"
    done
    
    echo "Done."
}

function create_config() {
    local user_id=$1
    echo "Creating new configuration for user: $user_id"
    curl -s -X POST "$API_URL/create/$user_id"
    echo -e "\nDone."
}


# Main script logic
if [ "$#" -lt 2 ]; then
    usage
    exit 1
fi

COMMAND=$1
USER_ID=$2

case "$COMMAND" in
    push)
        push_config "$USER_ID"
        ;;
    pull)
        pull_config "$USER_ID"
        ;;
    create)
        create_config "$USER_ID"
        ;;
    *)
        usage
        exit 1
        ;;
esac
