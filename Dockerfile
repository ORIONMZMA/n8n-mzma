# Use the latest official n8n image as it has Python and our dependencies installed
FROM n8nio/n8n:latest

# Switch to root user temporarily
USER root

# Ensure essential tools and potential Fabric dependencies are present
RUN apk update && \
    apk add --no-cache \
        git \
        python3 \
        curl \
        py3-flask && \
    rm -rf /var/cache/apk/*

# Download and install Fabric binary (same as before)
RUN echo "--- Downloading Fabric binary ---" && \
    curl -L https://github.com/danielmiessler/fabric/releases/latest/download/fabric-linux-amd64 -o /usr/local/bin/fabric && \
    chmod +x /usr/local/bin/fabric && \
    echo "--- Fabric binary downloaded ---"

# Set up the working directory for our app
WORKDIR /app

# Copy the Flask application code
COPY app.py .

# Create a non-root user to run the application (good practice)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chown -R appuser:appgroup /app
# Ensure Fabric config dir exists and is owned by appuser (if fabric needs it)
RUN mkdir -p /home/appuser/.config/fabric && chown -R appuser:appgroup /home/appuser/.config

# Switch to the non-root user
USER appuser

# Inform Docker that the container listens on port 5000 (Flask default)
EXPOSE 5000

# --- API Key Reminder ---
# REMINDER: You MUST set API keys (e.g., OPENAI_API_KEY)
# as environment variables in your Railway service configuration.

# Default command to run the Flask web server
# CHANGE: Use python3 instead of python
CMD ["python3", "app.py"]
