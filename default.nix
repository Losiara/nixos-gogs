{ pkgs ? import <nixpkgs> {} }:

pkgs.callPackage ./gogs.nix {
  tags = [ "sqlite" ];
}
