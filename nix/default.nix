{
  self,
  inputs,
  ...
}:

{
  perSystem =
    {
      pkgs,
      config,
      ...
    }:
    {
      pre-commit.check.enable = true;
      pre-commit.settings.hooks = {
        actionlint.enable = true;
        shellcheck.enable = true;
        deadnix.enable = true;
        deadnix.excludes = [ "nix/overlays/nodePackages/node2nix" ];
        nixfmt-rfc-style.enable = true;
      };
      devShells.default = pkgs.mkShell {
        shellHook = config.pre-commit.installationScript;
        buildInputs = config.pre-commit.settings.enabledPackages;
      };
      packages.cachex = pkgs.writeShellApplication {
        name = "cachex";
        runtimeInputs = with pkgs; [
          coreutils
          gnused
          envsubst
        ];
        text = ''
          NFS_DIR="$1"
          TIMESTAMP=$(date +%s)
          USAGE=$(df -h "$NFS_DIR" | tail -n1 || 0)
          TOTAL_CACHE=$(find "$NFS_DIR" -type f | wc -l)
          NICE=$(du -sh "$NFS_DIR")

          export TIMESTAMP
          export USAGE
          export TOTAL_CACHE
          export NICE
          envsubst < ${./cache.html.tpl}
        '';
      };
    };

  flake.nixosConfigurations.komunix-dev = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = inputs.nixpkgs.lib.attrValues self.nixosModules ++ [
      "${inputs.nixpkgs}/nixos/modules/profiles/macos-builder.nix"
      (
        { config, ... }:
        {
          services.cachex.enable = true;
          services.cachex.enableCron = true;
          services.cachex.workDir = config.users.users.komunix.home;
          services.cachex.cachexPackage = self.packages.aarch64-linux.cachex;
        }
      )
    ];
  };

  flake.nixosConfigurations.komunix = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = inputs.nixpkgs.lib.attrValues self.nixosModules ++ [
      (
        { config, ... }:
        {
          services.cachex.enable = true;
          services.cachex.enableCron = true;
          services.cachex.workDir = config.users.users.komunix.home;
          services.cachex.cachexPackage = self.packages.aarch64-linux.cachex;
        }
      )
    ];
  };

  flake.nixosModules.common = {
    system.stateVersion = "24.05";
    nix.settings.auto-optimise-store = true;
    nix.settings.fallback = true;
    nix.settings.experimental-features = [
      "flakes"
      "nix-command"
    ];
  };

  flake.nixosModules.maintainers =
    let
      keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDKvi3Co5fB1dSU2Qs1sR6LwdB1hM6HCyIWfXsC0wgz1pmeFlje24SzPCxDtsVMq28fDpEBsXPqKSZbUIyBtHRnpIc72Z8IV0KNtBjbKQTfHLTiDu43e+VLuAdFE7u2Wf5KPQIQ52r/jr9P7UKU2GKwV016OzrRiaZjm+gixmd8YRfidzG1bsL5fbKBjxCIUROdVpW5kNNtPZHpeuHCkZ7341USC6V2qnp1BNHIoHLjRYosV82apOxN/AWY/tMN2jlVQ/gKIUHbxXoILsG+XRFCen5TSSearx54KxifI1aIWbxVVmmYNuLXGWnVumaH6U7ARpz2cEXQB9z2lvJGYmod8qfloVdjXESu8OFe4RT+nj0JUQs7pMhiN6K1AsMQiyFc0ZmU2UNx4JcHre5STnSKUHUCx4zzoToFvIQRBTB3HePHy74FcXWaYDAN/6YF3JEA203nyYL4o5m/KhSXNkcT3H+r3IAqKnl7J7obsvNowwa1UB2NxVmq0VXXR8uZlT0="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBHnjecqMe2lrGzAvQ2VQRTXhjZ5q1tONgme+2/97Z3VSXdY0i2bEH3qGEIC7uMyWUfmLystXxqP0u6/Xspmm0Ck="
      ];
    in
    {
      users.users.root.openssh.authorizedKeys.keys = keys;
      users.users.komunix = {
        home = "/home/komunix";
        createHome = true;
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = keys;
      };
    };

  flake.nixosModules.services-cachex =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      cfg = config.services.cachex;
    in
    with lib;
    {
      options.services.cachex = {
        enable = mkOption {
          default = false;
          type = with types; bool;
          description = ''
            Enable caddy for cachex
          '';
        };
        enableCron = mkOption {
          default = false;
          type = with types; bool;
          description = ''
            Enable cachex in cron job
          '';
        };
        cachexPackage = mkOption {
          type = types.package;
          description = ''
            Cachex Package
          '';
        };
        caddyPackage = mkOption {
          default = pkgs.caddy;
          type = types.package;
          description = ''
            Caddy package
          '';
          example = literalExample "pkgs.caddy";
        };
        workDir = mkOption {
          type = types.str;
          example = literalExample "/home/komunix";
        };
        listenAddress = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = ''
            Listen Address
          '';
        };
        listenPort = mkOption {
          type = types.port;
          default = 2022;
          description = ''
            Listen Address
          '';
        };
      };
      config = mkIf cfg.enable {
        environment.systemPackages = [ cfg.caddyPackage ];

        services.cron.enable = cfg.enableCron;
        services.cron.systemCronJobs = [
          "* * * * * cachex ${getExe cfg.cachexPackage} > ${cfg.workDir}/cachex/index.html"
        ];

        system.activationScripts.createDir =
          # bash
          mkBefore ''
            [[ -d ${cfg.workDir}/cachex ]] || \
              (mkdir -p ${cfg.workDir}/cachex && chown komunix:users ${cfg.workDir}/cachex)

            # TODO: better way is using options `services.nfs.*` from `NixOS`.
            [[ -d ${cfg.workDir}/nfs ]] || \
              (mount -t nfs -O rw,username=komunix,uid=1030,gid=100 100.121.185.1:/volume2/komunix ${cfg.workDir}/nfs)

            ${getExe cfg.cachexPackage} ${cfg.workDir}/nfs > ${cfg.workDir}/cachex/index.html
          '';

        systemd.services.caddy = {
          unitConfig.Description = "Caddy";
          serviceConfig.StartLimitIntervalSec = 5;
          serviceConfig.StartLimitBurst = 10;
          serviceConfig.Restart = "always";
          serviceConfig.RestartSec = 10;
          serviceConfig.StandardOutput = null;
          serviceConfig.StandardError = "journal";
          serviceConfig.WorkingDirectory = cfg.workDir;
          serviceConfig.StateDirectory = "cachex";
          serviceConfig.RuntimeDirectory = "cachex";
          serviceConfig.ExecStart = # bash
            ''
              ${getExe cfg.caddyPackage} file-server --root ${cfg.workDir}/cachex --listen ${cfg.listenAddress}:${toString cfg.listenPort}
            '';
          wantedBy = [ "multi-user.target" ];
        };
      };
    };
}
