{ pkgs ? import <nixpkgs> {} }:

pkgs.callPackage ./gogs.nix {
  go = pkgs.go_1_4;
  tags = [ "sqlite" ];
}
