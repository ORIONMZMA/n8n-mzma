# Use the latest official n8n image
FROM n8nio/n8n:latest

# Switch to root user temporarily to install system packages
USER root

# Install Python, pip, and git (useful for fabric patterns/updates)
# Clean up apt cache afterwards to keep image size down
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 python3-pip git && \
    rm -rf /var/lib/apt/lists/*

# Install the latest version of fabric-ai using pip
# --no-cache-dir keeps image smaller
RUN pip install --no-cache-dir fabric-ai

# --- User and Data Directory ---
# Switch back to the non-root 'node' user that the base n8n image uses
USER node

# Create the Fabric config directory as the 'node' user
# Ensures Fabric has a place to potentially store configs or downloaded patterns
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

# The base n8n image already has the correct CMD/ENTRYPOINT to start nn8n.
# We don't need to specify it again.
