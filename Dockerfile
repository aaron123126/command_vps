# Use a Debian-based image
FROM debian:stable-slim

# Install Python, Flask, OpenSSH Server, and sudo
RUN apt-get update && apt-get install -y python3 python3-pip openssh-server python3-flask sudo

# Create a user for SSH access and add to sudo group
RUN useradd -ms /bin/bash admin
RUN usermod -aG sudo admin

# Set a password for the admin user (replace with a strong password)
RUN echo "admin:password" | chpasswd

# Create SSH directory for admin user
RUN mkdir /home/admin/.ssh
RUN chown -R admin:admin /home/admin/.ssh
RUN chmod 700 /home/admin/.ssh

# Copy the Python application into the container
COPY app.py /home/admin/app.py
RUN chown admin:admin /home/admin/app.py

# Expose ports for SSH and the web app
EXPOSE 22 8080

# Start the SSH server and the Python application
CMD service ssh start && su - admin -c "python3 /home/admin/app.py"
