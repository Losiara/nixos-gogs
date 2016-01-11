{
  network.description = "Gogs server";

  server =
    { config, pkgs, ... }:
    {
      imports = [ ./module.nix ];

      services.gogs.enable = true;
      services.gogs.package = pkgs.callPackage ./gogs.nix {
        go = pkgs.go_1_4;
        tags = [ "sqlite" ];
      };

      networking.firewall.allowedTCPPorts = [ 3000 ];

      deployment.targetEnv = "virtualbox";
      deployment.virtualbox.memorySize = 2048;
    };
}
