#!/bin/bash

# Start the SSH server in the background
/usr/sbin/sshd -D & 

# Start the Flask application
# Ensure the Python path is correct
cd /api
python3 index.py & 

# Keep the container running
wait -n
exit $?