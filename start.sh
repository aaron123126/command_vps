#!/bin/bash

# Build the Docker image
docker build -t my-vps .

# Run the Docker container
# This will map port 2222 on the host to port 22 in the container for SSH
# and port 8080 on the host to port 8080 in the container for the web app.
docker run -d -p 2222:22 -p 8080:8080 --name my-vps-container my-vps

echo "VPS container started."
echo "To SSH into the container, use: ssh admin@localhost -p 2222"
echo "The password is 'password'."
echo "To access the web app, open your browser to http://localhost:8080"
