pass-import-docker-image
================

Theory of Use
----------------

I needed a secure way to convert my KeePass database to Unix Pass

1. I wanted to do the conversion in an isolated environment, so I did this in docker

    * I happen to be using rootless podman to protect the host

2. I wanted to do the conversion without full trust of the conversion scripts,
   so we want to do it with no internet access

    * This is a difficult thing to do in rootless podman (no access to firewall rules),
      so I simply run it with no network access (`--net none`)


Use
----------------

First, load your public gpg key into the system default location (`~/.gnupg`).
The import process does not need the private key.

Ensure rootless podman is installed

Build the docker image:

    bash build.sh

Run the import process:

    bash run.sh <key-id> <database-file>

For example:

    bash run.sh user@example.com ~/my-database.kdbx

... and a fresh password store is created here:

    ./target/pass/

NOTE: Your input database is also copied to this directory:

    ./target/
