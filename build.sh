#!/bin/bash

# Stop on error
set -e -o pipefail

# Show commands
set -x

# Write out Dockerfile
cat << 'EOF' > Dockerfile
FROM alpine:latest

# TODO: Auto-identify the latest version through GitHub API
ENV PASS_IMPORT_VERSION=3.4

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
        python3 gpg-agent && \

    # Wipe apk cache (for smaller image)
    rm -rf /var/cache/apk/* && \

    # NOTE: We install everything PIP related via root
    # so that it's available to any UID provided by the caller

    # Install pass-import dependencies
    python3 -m ensurepip && \
    pip3 install requests setuptools pyaml zxcvbn pykeepass && \

    # Install pass-import
    wget "https://github.com/roddhjav/pass-import/releases/download/v${PASS_IMPORT_VERSION}/pass-import-${PASS_IMPORT_VERSION}.tar.gz" && \
    tar xzf "pass-import-${PASS_IMPORT_VERSION}.tar.gz" && \
    cd "pass-import-${PASS_IMPORT_VERSION}" && \
    python3 setup.py install

# Enable pass extensions (for the import extension)
ENV PASSWORD_STORE_ENABLE_EXTENSIONS=true

ENTRYPOINT ["pass"]

EOF

# TODO: Add --pull=newer when supported
podman build --tag pass-container:local-build .

