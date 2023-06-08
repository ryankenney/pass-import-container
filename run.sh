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

  key-id:
    The key ID to initialize the output repo with (to encrypt all entries with).
  database-file:
    The Keepass database file to import

EOF
    exit 1
}

if [[ ! $# -eq 2 ]]; then
    print_usage_and_exit
fi

KEY_ID="$1"
shift
DATABASE_FILE="$1"
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

# Copy database file where it can be used
cp "$DATABASE_FILE" target/
DATABASE_FILENAME="$(basename "$DATABASE_FILE")"

# Launch container for use with pass-import
podman run --rm -it \
  --security-opt label=disable \
  -e PASSWORD_STORE_DIR=/target/pass \
  -e PASSWORD_STORE_GIT=/target/pass \
  -v "$PWD/target:/target:rw" \
  `# TODO: Figure out how to run with ":ro" set` \
  -v "$HOME/.gnupg:/root/.gnupg:rw" \
  `# When host ".gnupg" is exposed to the container, disable the network` \
  --network none \
  --workdir /target/ \
  --name pass-container \
  pass-container \
  import keepass "$DATABASE_FILENAME" 

