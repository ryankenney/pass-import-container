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
      so I simply run it when the internet is disconnected (or in an offline VM)


Use
----------------

With rootless podman installed, we can build and run with:

```
bash build.sh
bash run.sh --help
```
