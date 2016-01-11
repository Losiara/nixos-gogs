{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.gogs;
  gogs = cfg.package;
  configFile = pkgs.writeText "app.ini" ''
    APP_NAME = ${cfg.appName}
    RUN_USER = ${cfg.user}
    RUN_MODE = ${cfg.mode}

    [database]
    DB_TYPE = ${cfg.database.type}
    HOST = 127.0.0.1:3306
    NAME = gogs
    USER = root
    PASSWD = 
    SSL_MODE = disable
    PATH = ${cfg.database.path}

    [repository]
    ROOT = ${cfg.repositoryRoot}

    [server]
    DOMAIN = ${cfg.domain}
    HTTP_PORT = ${toString cfg.httpPort}
    ROOT_URL = ${cfg.rootUrl}
    DISABLE_SSH = false
    SSH_PORT = 22
    OFFLINE_MODE = false

    [mailer]
    ENABLED = false

    [service]
    REGISTER_EMAIL_CONFIRM = false
    ENABLE_NOTIFY_MAIL = false
    DISABLE_REGISTRATION = false
    ENABLE_CAPTCHA = true
    REQUIRE_SIGNIN_VIEW = false

    [picture]
    DISABLE_GRAVATAR = false

    [session]
    PROVIDER = file

    [log]
    MODE = file
    LEVEL = Info

    [security]
    INSTALL_LOCK = true
    SECRET_KEY = sUL4k5gCb0qRuoS
  '';
in

{
  options = {
    services.gogs = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = "
          Enable Gogs.
        ";
      };

      package = mkOption {
        default = pkgs.callPackage ./gogs.nix;
        type = types.package;
        description = "
          Gogs package to use.
        ";
      };

      stateDir = mkOption {
        default = "/var/spool/gogs";
        type = types.str;
        description = "
          Directory holding all state for Gogs to run.
        ";
      };

      user = mkOption {
        type = types.str;
        default = "git";
        description = "User account under which Gogs runs.";
      };

      group = mkOption {
        type = types.str;
        default = "git";
        description = "Group account under which Gogs runs.";
      };

      appName = mkOption {
        type = types.str;
        default = "Gogs: Go Git Service";
      };

      mode = mkOption {
        type = types.str;
        default = "prod";
      };

      database = {
        type = mkOption {
          type = types.str;
          default = "sqlite3";
        };

        path = mkOption {
          type = types.str;
          default = "${cfg.stateDir}/data/gogs.db";
        };
      };

      repositoryRoot = mkOption {
        type = types.str;
        default = "${cfg.stateDir}/repositories";
      };

      domain = mkOption {
        type = types.str;
        default = "localhost";
      };

      httpPort = mkOption {
        type = types.int;
        default = 3000;
      };

      rootUrl = mkOption {
        type = types.str;
        default = "http://localhost:3000/";
      };

# DISABLE_SSH = false
# SSH_PORT = 22
# OFFLINE_MODE = false

# [mailer]
# ENABLED = false
# 
# [service]
# REGISTER_EMAIL_CONFIRM = false
# ENABLE_NOTIFY_MAIL = false
# DISABLE_REGISTRATION = false
# ENABLE_CAPTCHA = true
# REQUIRE_SIGNIN_VIEW = false

# [picture]
# DISABLE_GRAVATAR = false
# 
# [session]
# PROVIDER = file
# 
# [log]
# MODE = file
# LEVEL = Info
# 
# [security]
# INSTALL_LOCK = true
# SECRET_KEY = sUL4k5gCb0qRuoS

    };

  };

  config = mkIf cfg.enable {

    systemd.services.gogs = {
      description = "Gogs (Go Git Service)";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ gogs ];

      preStart = ''
        mkdir -p ${cfg.stateDir}/custom/conf
        cp -f ${configFile} ${cfg.stateDir}/custom/conf/app.ini
        ln -fs ${gogs.src}/src/${gogs.url}/{public,templates} ${cfg.stateDir}/
      '';

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.stateDir;
        ExecStart = "${gogs}/bin/gogs web";
        Restart = "always";
      };

      environment.GOGS_WORK_DIR = cfg.stateDir;
    };

    users.extraUsers = optionalAttrs (cfg.user == "git") (singleton {
      name = "git";
      group = cfg.group;
      uid = config.ids.uids.git;
      createHome = true;
      home = cfg.stateDir;
    });

    users.extraGroups = optionalAttrs (cfg.group == "git") (singleton {
      name = "git";
      gid = config.ids.gids.git;
    });
  };
}
