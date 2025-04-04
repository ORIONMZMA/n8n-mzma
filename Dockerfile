# Use the latest official n8n image (based on Alpine Linux)
FROM n8nio/n8n:latest

# Switch to root user temporarily to install system packages
USER root

# Step 1: Install base runtime dependencies
RUN apk update && \
    apk add --no-cache python3 py3-pip git

# Step 2: Install build dependencies separately
# These are needed to compile some Python packages
RUN apk add --no-cache build-base python3-dev musl-dev linux-headers

# Step 3: Install fabric-ai with verbose output
# --no-cache-dir is still good practice
# The '-v' flag provides more detailed logs if pip fails
RUN pip install -v --no-cache-dir fabric-ai

# Step 4: Remove build dependencies now that pip install is done
# We don't need these in the final runtime image
# Using --virtual in Step 2 wasn't easily compatible with separating RUN steps, so we list them manually
RUN apk del build-base python3-dev musl-dev linux-headers

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
