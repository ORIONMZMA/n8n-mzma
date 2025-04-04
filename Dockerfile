# Use the latest official n8n image (based on Alpine Linux)
FROM n8nio/n8n:latest

# Switch to root user temporarily to install system packages
USER root

# Use Alpine's package manager 'apk'
# Update index, install Python3, pip for Python3, and git
# Also install build dependencies needed for some pip packages
# Use a virtual package (.build-deps) to easily remove build deps later in the same layer
RUN apk update && \
    apk add --no-cache python3 py3-pip git && \
    apk add --virtual .build-deps build-base python3-dev musl-dev linux-headers && \
    \
    # Install the latest version of fabric-ai using pip
    # --no-cache-dir keeps image smaller, happens during pip install
    pip install --no-cache-dir fabric-ai && \
    \
    # Remove build dependencies now that pip install is done to keep image lean
    apk del .build-deps

# --- User and Data Directory ---
# Switch back to the non-root 'node' user that the base n8n image uses
USER node

# Create the Fabric config directory as the 'node' user
RUN mkdir -p /home/node/.config/fabric

# (Optional but good practice) Explicitly set the working directory
WORKDIR /home/node

# (Required for persistence) Define where n8n data should be stored INSIDE the container.
# Render will mount your persistent disk to this path.
# Ensure your Render Disk mount path is set to match this.
ENV N8N_USER_FOLDER=/home/node/.n8n

# --- API Key Reminder ---
# REMINDER: You MUST set the required API keys for Fabric (e.g., OPENAI_API_KEY for Whisper)
# as environment variables in your Render service configuration.
# Fabric will automatically detect and use keys like OPENAI_API_KEY, ANTHROPIC_API_KEY etc.
# Example: OPENAI_API_KEY=sk-xxxxxxxxxxx

# The base n8n image already has the correct CMD/ENTRYPOINT to start n8n.
# We don't need to specify it again.
