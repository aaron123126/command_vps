#!/bin/bash

# This script acts as a custom shell for SSH users to manage configurations.

AUTH_TOKEN="${AUTH_TOKEN}" # Passed from Docker environment

if [ -z "$AUTH_TOKEN" ]; then
    echo "Error: AUTH_TOKEN is not set. Cannot proceed."
    exit 1
fi

SERVER_URL="http://localhost:8080/api/config" # Flask server inside the container

function config_pull() {
    USER_ID=$1
    if [ -z "$USER_ID" ]; then
        echo "Usage: config pull <USER_ID>"
        return 1
    fi
    echo "Pulling config for user: $USER_ID..."
    curl -s -H "X-Auth-Token: $AUTH_TOKEN" "$SERVER_URL/$USER_ID" > "/tmp/config_${USER_ID}.json"
    if [ $? -eq 0 ]; then
        echo "Config pulled and saved to /tmp/config_${USER_ID}.json"
        cat "/tmp/config_${USER_ID}.json"
    else
        echo "Failed to pull config."
    fi
}

function config_push() {
    USER_ID=$1
    CONFIG_FILE=$2
    if [ -z "$USER_ID" ] || [ -z "$CONFIG_FILE" ]; then
        echo "Usage: config push <USER_ID> <PATH_TO_CONFIG_FILE>"
        return 1
    fi
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Error: Config file not found: $CONFIG_FILE"
        return 1
    fi
    echo "Pushing config for user: $USER_ID from $CONFIG_FILE..."
    curl -s -X POST -H "Content-Type: application/json" -H "X-Auth-Token: $AUTH_TOKEN" -d "@$CONFIG_FILE" "$SERVER_URL/$USER_ID"
    if [ $? -eq 0 ]; then
        echo "Config pushed successfully."
    else
        echo "Failed to push config."
    fi
}

function config_create() {
    USER_ID=$1
    if [ -z "$USER_ID" ]; then
        echo "Usage: config create <NEW_USER_ID>"
        return 1
    }
    echo "Creating new config for user: $USER_ID..."
    curl -s -X POST -H "X-Auth-Token: $AUTH_TOKEN" "$SERVER_URL/create/$USER_ID"
    if [ $? -eq 0 ]; then
        echo "New config created successfully."
    else
        echo "Failed to create new config."
    }
}

function config_del() {
    USER_ID=$1
    if [ -z "$USER_ID" ]; then
        echo "Usage: config del <USER_ID>"
        return 1
    }
    echo "Deleting config for user: $USER_ID..."
    curl -s -X DELETE -H "X-Auth-Token: $AUTH_TOKEN" "$SERVER_URL/$USER_ID"
    if [ $? -eq 0 ]; then
        echo "Config for $USER_ID deleted successfully from server."
    else
        echo "Failed to delete config from server."
    }
}

function config_reset() {
    USER_ID=$1
    if [ -z "$USER_ID" ]; then
        echo "Usage: config reset <USER_ID>"
        return 1
    }
    LOCAL_CONFIG_FILE="/tmp/config_${USER_ID}.json"
    if [ -f "$LOCAL_CONFIG_FILE" ]; then
        rm "$LOCAL_CONFIG_FILE"
        echo "Local config for $USER_ID reset (deleted $LOCAL_CONFIG_FILE)."
    else
        echo "No local config found for $USER_ID to reset."
    }
}

# Main loop for the custom shell
echo "Welcome to the VPS Config Manager."
echo "Available commands: config pull <USER_ID>, config push <USER_ID> <PATH_TO_CONFIG_FILE>, config create <NEW_USER_ID>, config del <USER_ID>, config reset <USER_ID>"
echo "Type 'exit' to quit."

while true; do
    read -p "vps-config> " command_line
    read -ra ADDR <<< "$command_line" # read into an array
    COMMAND=${ADDR[0]}
    ARG1=${ADDR[1]}
    ARG2=${ADDR[2]}

    case "$COMMAND" in
        "config")
            SUB_COMMAND=${ADDR[1]}
            ARG1=${ADDR[2]}
            ARG2=${ADDR[3]}
            case "$SUB_COMMAND" in
                "pull")
                    config_pull "$ARG1"
                    ;;
                "push")
                    config_push "$ARG1" "$ARG2"
                    ;;
                "create")
                    config_create "$ARG1"
                    ;;
                "del")
                    config_del "$ARG1"
                    ;;
                "reset")
                    config_reset "$ARG1"
                    ;;
                *)
                    echo "Unknown config subcommand: $SUB_COMMAND"
                    echo "Available commands: config pull <USER_ID>, config push <USER_ID> <PATH_TO_CONFIG_FILE>, config create <NEW_USER_ID>, config del <USER_ID>, config reset <USER_ID>"
                    ;;
            esac
            ;;
        "exit")
            echo "Exiting."
            break
            ;;
        "")
            # Empty command, do nothing
            ;;
        *)
            echo "Unknown command: $COMMAND"
            echo "Available commands: config pull <USER_ID>, config push <USER_ID> <PATH_TO_CONFIG_FILE>, config create <NEW_USER_ID>, config del <USER_ID>, config reset <USER_ID>"
            ;;
    esac
done

# Main loop for the custom shell
echo "Welcome to the VPS Config Manager."
echo "Available commands: config pull <USER_ID>, config push <USER_ID> <PATH_TO_CONFIG_FILE>, config create <NEW_USER_ID>"
echo "Type 'exit' to quit."

while true; do
    read -p "vps-config> " command_line
    read -ra ADDR <<< "$command_line" # read into an array
    COMMAND=${ADDR[0]}
    ARG1=${ADDR[1]}
    ARG2=${ADDR[2]}

    case "$COMMAND" in
        "config")
            SUB_COMMAND=${ADDR[1]}
            ARG1=${ADDR[2]}
            ARG2=${ADDR[3]}
            case "$SUB_COMMAND" in
                "pull")
                    config_pull "$ARG1"
                    ;;
                "push")
                    config_push "$ARG1" "$ARG2"
                    ;;
                "create")
                    config_create "$ARG1"
                    ;;
                *)
                    echo "Unknown config subcommand: $SUB_COMMAND"
                    echo "Available commands: config pull <USER_ID>, config push <USER_ID> <PATH_TO_CONFIG_FILE>, config create <NEW_USER_ID>"
                    ;;
            esac
            ;;
        "exit")
            echo "Exiting."
            break
            ;;
        "")
            # Empty command, do nothing
            ;;
        *)
            echo "Unknown command: $COMMAND"
            echo "Available commands: config pull <USER_ID>, config push <USER_ID> <PATH_TO_CONFIG_FILE>, config create <NEW_USER_ID>"
            ;;
    esac
done