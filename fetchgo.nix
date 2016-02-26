{ stdenv, go, git, cacert, url, rev, tags ? [] }:

stdenv.mkDerivation {
  name = builtins.replaceStrings ["/"] ["_"] url;
  buildInputs = [ go git cacert ];

  phases = [ "installPhase" ];

  installPhase = ''
    export GIT_SSL_CAINFO=$cacert/etc/ssl/certs/ca-bundle.crt
    export GOPATH=$out
    repo=$out/src/${url}
    mkdir -p $repo
    git clone https://${url}.git $repo
    cd $repo
    git reset --hard ${rev}
    go get -d -tags '${builtins.concatStringsSep " " tags}'
  '';

  inherit cacert;
}
