#!/bin/bash

# Stop on error
set -e -o pipefail

# Show commands
set -x

SCRIPT_FILE="$(basename "$0")"
# NOTE: readlink will not work in OSX
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

function print_usage_and_exit() {
    cat << EOF >&2

USAGE: $SCRIPT_FILE <key-id>

  key-id: The key ID to initialize the output repo with (to encrypt all entries with).

EOF
    exit 1
}

if [[ ! $# -eq 1 ]]; then
    print_usage_and_exit
fi

KEY_ID="$1"
shift

mkdir -p "$SCRIPT_DIR/target/pass"
rm -rf "$SCRIPT_DIR/target/pass"
mkdir -p "$SCRIPT_DIR/target/pass"

# Initialize the pass repo dir
podman run --rm -it \
  --security-opt label=disable \
  -e PASSWORD_STORE_DIR=/target/pass \
  -e PASSWORD_STORE_GIT=/target/pass \
  -v "$PWD/target:/target" \
  -v "$HOME/.gnupg:/root/.gnupg:ro" \
  --workdir /target/ \
  --name pass-container pass-container \
  init "$KEY_ID"

# Launch container for use with pass-import
podman run --rm -it \
  --security-opt label=disable \
  -e PASSWORD_STORE_DIR=/target/pass \
  -e PASSWORD_STORE_GIT=/target/pass \
  -v "$PWD/target:/target:rw" \
  -v "$PWD/import:/import:ro" \
  `# TODO: Figure out how to run with ":ro" set` \
  -v "$HOME/.gnupg:/root/.gnupg:rw" \
  `# When host ".gnupg" is exposed to the container, disable the network` \
  --network none \
  --workdir /target/ \
  --entrypoint /bin/bash \
  --name pass-container pass-container

