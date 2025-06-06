{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.haproxy;
  haproxyCfg = pkgs.writeText "haproxy.conf" ''
    global
      # needed for hot-reload to work without dropping packets in multi-worker mode
      stats socket /run/haproxy/haproxy.sock mode 600 expose-fd listeners level user
    ${cfg.config}
  '';
in
{
  options = {
    services.haproxy = {

      enable = lib.mkEnableOption "HAProxy, the reliable, high performance TCP/HTTP load balancer";

      package = lib.mkPackageOption pkgs "haproxy" { };

      user = lib.mkOption {
        type = lib.types.str;
        default = "haproxy";
        description = "User account under which haproxy runs.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "haproxy";
        description = "Group account under which haproxy runs.";
      };

      config = lib.mkOption {
        type = lib.types.nullOr lib.types.lines;
        default = null;
        description = ''
          Contents of the HAProxy configuration file,
          {file}`haproxy.conf`.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = cfg.config != null;
        message = "You must provide services.haproxy.config.";
      }
    ];

    # configuration file indirection is needed to support reloading
    environment.etc."haproxy.cfg".source = haproxyCfg;

    systemd.services.haproxy = {
      description = "HAProxy";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Type = "notify";
        ExecStartPre = [
          # when the master process receives USR2, it reloads itself using exec(argv[0]),
          # so we create a symlink there and update it before reloading
          "${pkgs.coreutils}/bin/ln -sf ${lib.getExe cfg.package} /run/haproxy/haproxy"
          # when running the config test, don't be quiet so we can see what goes wrong
          "/run/haproxy/haproxy -c -f ${haproxyCfg}"
        ];
        ExecStart = "/run/haproxy/haproxy -Ws -f /etc/haproxy.cfg -p /run/haproxy/haproxy.pid";
        # support reloading
        ExecReload = [
          "${lib.getExe cfg.package} -c -f ${haproxyCfg}"
          "${pkgs.coreutils}/bin/ln -sf ${lib.getExe cfg.package} /run/haproxy/haproxy"
          "${pkgs.coreutils}/bin/kill -USR2 $MAINPID"
        ];
        KillMode = "mixed";
        SuccessExitStatus = "143";
        Restart = "always";
        RuntimeDirectory = "haproxy";
        # upstream hardening options
        NoNewPrivileges = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        SystemCallFilter = "~@cpu-emulation @keyring @module @obsolete @raw-io @reboot @swap @sync";
        # needed in case we bind to port < 1024
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
      };
    };

    users.users = lib.optionalAttrs (cfg.user == "haproxy") {
      haproxy = {
        group = cfg.group;
        isSystemUser = true;
      };
    };

    users.groups = lib.optionalAttrs (cfg.group == "haproxy") {
      haproxy = { };
    };
  };
}
