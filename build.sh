#!/bin/bash

# Stop on error
set -e -o pipefail

# Show commands
set -x

# Write out Dockerfile
cat << 'EOF' > Dockerfile
FROM alpine:latest

RUN \
    # Show each comand as we build
    set +x && \

    # Refresh apk cache
    apk update && \

    apk add --update \
        # Install pass
        pass \
        # Install git (for cloning)
        git \
        # Install pass-import dependencies
        python3 && \

    # Wipe apk cache (for smaller image)
    rm -rf /var/cache/apk/* && \

    # NOTE: We install everything PIP related via root
    # so that it's available to any UID provided by the caller

    # Install pass-import dependencies
    python3 -m ensurepip && \

    # Install pass-import
    pip3 install pass-import

# Enable pass extensions (for the import extension)
ENV PASSWORD_STORE_ENABLE_EXTENSIONS=true

ENTRYPOINT ["pass"]

EOF

# TODO: Add --pull=newer when supported
podman build --tag pass-container:local-build .

