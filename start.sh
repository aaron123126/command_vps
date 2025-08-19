#!/bin/bash

# Set the authentication token for the web server.
# IMPORTANT: Change 'your_secret_password_here' to a strong, unique password.
AUTH_TOKEN="your_secret_password_here"

# Build the Docker image
docker build -t my-vps .

# Run the Docker container
# This will map port 2222 on the host to port 22 in the container for SSH
# and port 8080 on the host to port 8080 in the container for the web app.
# Pass the AUTH_TOKEN as an environment variable to the container.
docker run -d -p 2222:22 -p 8080:8080 -e AUTH_TOKEN="$AUTH_TOKEN" --name my-vps-container my-vps

echo "VPS container started."
echo "To SSH into the container, use: ssh admin@localhost -p 2222"
echo "The password is 'password'."
echo "To access the web app, open your browser to http://localhost:8080"
