# Use an official Python runtime as a parent image
FROM python:3.11-slim
LABEL author="Ivor Scott Cummings <ivor@devpie.io>"
LABEL version="1.0.0"

# Install pgcli
RUN apt-get update && apt-get install -y --no-install-recommends \
    jq less libpq-dev \
    && pip install --no-cache-dir pgcli \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy the entrypoint script and Python script
COPY entrypoint.sh /entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x /entrypoint.sh
ENV PAGER="less -SRXF"
# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]