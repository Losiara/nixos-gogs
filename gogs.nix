{ stdenv, callPackage, makeWrapper, go, git, tags ? [] }:

let
  url = "github.com/gogits/gogs";
  rev = "d324500959c06e975921790f8770aa5d1bdf2344";
  fetchgo = callPackage (import ./fetchgo.nix);
in

stdenv.mkDerivation {
  name = "gogs";

  inherit url;

  src = fetchgo {
    inherit go url rev tags;
  };

  buildInputs = [ makeWrapper go git ];

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    export GOPATH=$PWD
    go install -tags '${builtins.concatStringsSep " " tags}' ${url}
    mkdir -p $out
    cp -r bin $out
    wrapProgram $out/bin/gogs --set GOGS_WORK_DIR . --prefix PATH : ${git}/bin
  '';
}
