#!/bin/bash

# Stop on error
set -e -o pipefail

# Show commands
set -x

podman run --rm -it --name pass-container pass-container "$@"
