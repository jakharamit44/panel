# Use a lightweight base image
FROM ubuntu:20.04

# Set environment variables to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install necessary packages
RUN apt-get update && \
    apt-get install -y \
    curl \
    lsof \
    iproute2 && \
    rm -rf /var/lib/apt/lists/*

# Check for root permissions - Not needed in Dockerfile, since Docker runs as root by default

# Check if running inside a container - This part can be omitted as this is always true inside Docker
# Check for port 80 usage
RUN lsof -i :80 >/dev/null && \
    echo "Error: something is already running on port 80" && \
    exit 1 || true

# Check for port 443 usage
RUN lsof -i :443 >/dev/null && \
    echo "Error: something is already running on port 443" && \
    exit 1 || true

# Install Docker (Docker-in-Docker, or DinD)
RUN if ! command -v docker >/dev/null 2>&1; then \
    curl -sSL https://get.docker.com | sh; \
    fi

# Pull the easypanel image
RUN docker pull easypanel/easypanel:latest

# Create necessary volumes for easypanel
VOLUME ["/etc/easypanel", "/var/run/docker.sock"]

# Run easypanel setup during the container run
CMD ["docker", "run", "--rm", "-i", \
     "-v", "/etc/easypanel:/etc/easypanel", \
     "-v", "/var/run/docker.sock:/var/run/docker.sock:ro", \
     "easypanel/easypanel", "setup"]
