# Use the latest official n8n image (based on Alpine Linux)
FROM n8nio/n8n:latest

# Switch to root user temporarily to install system packages and the binary
USER root

# Step 1: Install dependencies
# - git, python3: Potentially needed by some Fabric patterns or underlying processes.
# - ffmpeg, yt-dlp: Required by Fabric patterns that process video/audio (like YouTube transcription).
# - curl: Kept for downloading binary, testing network connectivity, and potentially used by some patterns.
RUN apk update && \
    apk add --no-cache \
        git \
        python3 \
        ffmpeg \
        yt-dlp \
        curl

# Step 2: Download the Fabric binary, place it in a standard location, and make it executable
RUN echo "--- Downloading Fabric binary ---" && \
    curl -L https://github.com/danielmiessler/fabric/releases/latest/download/fabric-linux-amd64 -o /usr/local/bin/fabric && \
    chmod +x /usr/local/bin/fabric && \
    echo "--- Fabric binary downloaded and made executable ---"

# Step 3: Copy and prepare the wrapper script to handle non-interactive execution
# Assumes 'fabric-wrapper.sh' is in the same directory as the Dockerfile during build
COPY fabric-wrapper.sh /usr/local/bin/fabric-n8n
RUN chmod +x /usr/local/bin/fabric-n8n

# Step 4: Verify installations (Optional but recommended)
# Testing the wrapper and other key dependencies
RUN echo "--- Verifying installations ---" && \
    echo "Testing Fabric wrapper:" && \
    fabric-n8n --version && \
    echo "Testing curl:" && \
    curl --version && \
    echo "Testing ffmpeg:" && \
    ffmpeg -version && \
    echo "Testing yt-dlp:" && \
    yt-dlp --version && \
    echo "--- Verification complete ---"

# NOTE: We are NOT removing curl, ffmpeg, yt-dlp etc. in a cleanup step
# as they might be needed at runtime by Fabric patterns or for debugging.

# --- User and Data Directory ---
# Switch back to the non-root 'node' user that the base n8n image uses
USER node

# Create the Fabric config directory as the 'node' user (still good practice)
# Fabric might create/use ~/.config/fabric automatically now
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

