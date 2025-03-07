# Use Alpine Linux for a small image size
FROM alpine:3.18

LABEL org.opencontainers.image.source="https://github.com/your-org/conjur-policy-action"
LABEL org.opencontainers.image.description="GitHub Action for loading Conjur Policy as Code"
LABEL org.opencontainers.image.licenses="MIT"

# Install dependencies
RUN apk add --no-cache \
    bash \
    curl \
    jq

# Copy action code
COPY . /action

# Set the entrypoint
ENTRYPOINT ["/action/entrypoint.sh"]