#!/bin/bash

# Specify the name of your Python script
SCRIPT_NAME="robot_config.py"

# Check if the script exists in the current directory
if [ -f "$SCRIPT_NAME" ]; then
    # Check if /usr/local/bin is writable
    if [ -w "/usr/local/bin" ]; then
        # Copy the script to /usr/local/bin
        sudo cp "$SCRIPT_NAME" "/usr/local/bin"
        sudo chmod +x "/usr/local/bin/$SCRIPT_NAME"
        echo "Script '$SCRIPT_NAME' has been installed in /usr/local/bin."
    else
        echo "Error: /usr/local/bin is not writable. You may need to use 'sudo' to install the script."
    fi
else
    echo "Error: Script '$SCRIPT_NAME' not found in the current directory."
fi
