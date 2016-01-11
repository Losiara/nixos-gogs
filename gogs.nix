{ stdenv, callPackage, makeWrapper, go, git, tags ? [] }:

let
  url = "github.com/gogits/gogs";
  fetchgo = callPackage (import ./fetchgo.nix);
in

stdenv.mkDerivation {
  name = "gogs";

  inherit url;

  src = fetchgo {
    inherit go url tags;
  };

  buildInputs = [ makeWrapper go git ];

  phases = [ "unpackPhase" "patchPhase" "installPhase" ];

  patches = [ ./render.go.patch ];

  installPhase = ''
    export GOPATH=$PWD
    go install -tags '${builtins.concatStringsSep " " tags}' ${url}
    mkdir -p $out
    cp -r bin $out
    wrapProgram $out/bin/gogs --set GOGS_WORK_DIR . --prefix PATH : ${git}/bin
  '';
}
