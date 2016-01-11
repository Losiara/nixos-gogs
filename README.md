# gogs-nixos

> [WIP] Deploy Gogs on NixOS.

## Usage

```sh
nixops create server.nix -d gogs
nixops deploy -d gogs
echo "http://$(nixops info -d gogs --plain | awk '{print $5}'):3000/"
```
