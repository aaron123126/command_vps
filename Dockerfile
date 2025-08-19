# Use a Debian-based image
FROM debian:stable-slim

# Install dependencies: Python, SSH, sudo for admin, and curl/jq for the config script
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    openssh-server \
    sudo \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Argument for the admin password, can be set during build
ARG ADMIN_PASSWORD=password

# Create a user for SSH access, add to sudo group, and set password
RUN useradd -ms /bin/bash admin && \
    usermod -aG sudo admin && \
    echo "admin:$ADMIN_PASSWORD" | chpasswd

# Create SSH directory for admin user
RUN mkdir -p /home/admin/.ssh && \
    chown -R admin:admin /home/admin/.ssh && \
    chmod 700 /home/admin/.ssh

# Create a directory for user-specific configuration files
RUN mkdir -p /home/admin/config_files && \
    chown -R admin:admin /home/admin/config_files

# Copy the custom VPS CLI script into the container and make it executable
COPY scripts/vps_cli.sh /usr/local/bin/vps_cli.sh
RUN chmod +x /usr/local/bin/vps_cli.sh

# Set the custom VPS CLI script as the default shell for the admin user
RUN usermod -s /usr/local/bin/vps_cli.sh admin

# Copy the original config.sh if it's still needed for other purposes
# If config.sh is no longer needed, this line can be removed.
COPY scripts/config.sh /usr/local/bin/config
RUN chmod +x /usr/local/bin/config

# Environment variable for the Vercel domain, to be set at runtime
ENV VERCEL_DOMAIN=""

COPY api /api
RUN pip3 install -r /api/requirements.txt

# Copy the start_services.sh script into the container and make it executable
COPY scripts/start_services.sh /usr/local/bin/start_services.sh
RUN chmod +x /usr/local/bin/start_services.sh

# Expose ports for SSH and the web app
EXPOSE 22 8080

# Start both SSH and the Flask web app
CMD ["/usr/local/bin/start_services.sh"]
