# Use the latest official n8n image (based on Alpine Linux)
FROM n8nio/n8n:latest

# Switch to root user temporarily to install system packages and the binary
USER root

# Step 1: Install dependencies needed for download (curl) and potentially by Fabric internally (git, python3 - keep just in case)
# Removed py3-pip as we are not using pip install
# Removed build dependencies as we are not compiling
RUN apk update && \
    apk add --no-cache curl git python3

# Step 2: Download the Fabric binary, place it in a standard location, and make it executable
# Using the official instructions from the Fabric README for Linux AMD64
# /usr/local/bin is typically in the PATH
RUN echo "--- Downloading Fabric binary ---" && \
    curl -L https://github.com/danielmiessler/fabric/releases/latest/download/fabric-linux-amd64 -o /usr/local/bin/fabric && \
    chmod +x /usr/local/bin/fabric && \
    echo "--- Fabric binary downloaded and made executable ---"

# Step 3: Verify Fabric installation (Optional but recommended)
RUN echo "--- Verifying Fabric installation ---" && \
    fabric --version && \
    echo "--- Fabric verification complete ---"

# Step 4: Clean up downloaded packages not strictly needed at runtime (curl can be removed)
RUN apk del curl

# --- User and Data Directory ---
# Switch back to the non-root 'node' user that the base n8n image uses
USER node

# Create the Fabric config directory as the 'node' user (still good practice)
# Note: Fabric might create/use ~/.config/fabric automatically now
RUN mkdir -p /home/node/.config/fabric

# (Optional but good practice) Explicitly set the working directory
WORKDIR /home/node

# (Required for persistence) Define where n8n data should be stored INSIDE the container.
# Render will mount your persistent disk to this path.
# Ensure your Render Disk mount path is set to match this.
ENV N8N_USER_FOLDER=/home/node/.n8n

# --- API Key Reminder ---
# REMINDER: You MUST set the required API keys for Fabric (e.g., OPENAI_API_KEY)
# as environment variables in your Render service configuration. Fabric uses these directly.
# Example: OPENAI_API_KEY=sk-xxxxxxxxxxx

# The base n8n image already has the correct CMD/ENTRYPOINT to start n8n.
# We don't need to specify it again.
