{ stdenv, go, git, cacert, url, tags ? [] }:

stdenv.mkDerivation {
  name = builtins.replaceStrings ["/"] ["_"] url;
  buildInputs = [ go git cacert ];

  phases = [ "installPhase" ];

  installPhase = ''
    export GIT_SSL_CAINFO=$cacert/etc/ssl/certs/ca-bundle.crt
    export GOPATH=$out
    go get -d -tags '${builtins.concatStringsSep " " tags}' ${url}
  '';

  inherit cacert;
}
