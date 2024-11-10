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
          USAGE=$(timeout 5s df -h "$NFS_DIR" | tail -n1 || echo "0")
          TOTAL_CACHE=$(find "$NFS_DIR" -type f | wc -l || echo "0")
          NICE=$(du -sh "$NFS_DIR" || echo "0")

          export TIMESTAMP
          export USAGE
          export TOTAL_CACHE
          export NICE
          envsubst < ${./cache.html.tpl}
        '';
      };
    };

  /**
    Build image for Raspberry Pi:
    `nix build .#nixosConfigurations.komunix-pi.config.system.build.sdImage` to build the sd card image, and
    `nix build .#nixosConfigurations.komunix-pi.config.system.build.toplevel` to build (only) the system
  */
  flake.nixosConfigurations.komunix-pi = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = inputs.nixpkgs.lib.attrValues self.nixosModules ++ [
      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
      (
        { config, ... }:
        {
          services.cachex.enable = true;
          services.cachex.cachexPackage = self.packages.aarch64-linux.cachex;
          services.cachex.settings.cron = true;
          services.cachex.settings.workDir = config.users.users.komunix.home;
        }
      )
    ];
  };

  flake.nixosConfigurations.komunix-dev = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = inputs.nixpkgs.lib.attrValues self.nixosModules ++ [
      "${inputs.nixpkgs}/nixos/modules/profiles/macos-builder.nix"
      (
        { config, ... }:
        {
          networking.hostName = "komunix-dev";
          services.cachex.enable = true;
          services.cachex.cachexPackage = self.packages.aarch64-linux.cachex;
          services.cachex.settings.cron = true;
          services.cachex.settings.workDir = config.users.users.komunix.home;
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
          services.cachex.cachexPackage = self.packages.aarch64-linux.cachex;
          services.cachex.settings.cron = true;
          services.cachex.settings.workDir = config.users.users.komunix.home;
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
      config,
      ...
    }:
    {

      services.tailscale.enable = true;
      services.tailscale.authKeyFile = config.sops.secrets.tailscale_auth_key.path;
      services.tailscale.extraUpFlags = [ "--ssh" ];

      users.users.root.openssh.authorizedKeys.keys = keys;
      users.users.komunix = {
        home = "/home/komunix";
        createHome = true;
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        openssh.authorizedKeys.keys = keys;
      };

      imports = [
        inputs.sops.nixosModules.sops
      ];

      sops.defaultSopsFile = ../secrets/secret.yaml;
      sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      sops.age.keyFile = "/var/lib/sops-nix/key.txt";
      sops.age.generateKey = true;
      sops.secrets.tailscale_auth_key = { };
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
        settings.cron = mkOption {
          default = false;
          type = with types; bool;
          description = ''
            Enable cachex in cron job
          '';
        };
        settings.workDir = mkOption {
          type = types.str;
          example = literalExample "/home/komunix";
        };
        settings.listenAddress = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = ''
            Listen Address
          '';
        };
        settings.listenPort = mkOption {
          type = types.port;
          default = 2022;
          description = ''
            Listen Address
          '';
        };
      };

      config = mkIf cfg.enable {
        environment.systemPackages = [ cfg.caddyPackage ];

        services.cron.enable = cfg.settings.cron;
        services.cron.systemCronJobs = [
          "* * * * * cachex ${getExe cfg.cachexPackage} > ${cfg.settings.workDir}/cachex/index.html"
        ];

        services.rpcbind.enable = true; # needed for NFS
        systemd.mounts = [
          {
            type = "nfs";
            mountConfig = {
              Options = "noatime";
            };
            what = "100.121.185.1:/volume2/komunix";
            where = "${cfg.settings.workDir}/nfs";
          }
        ];
        systemd.automounts = [
          {
            wantedBy = [ "multi-user.target" ];
            automountConfig = {
              TimeoutIdleSec = "600";
            };
            where = "${cfg.settings.workDir}/nfs";
          }
        ];

        system.activationScripts.createDir =
          # bash
          mkBefore ''
            [[ -d ${cfg.settings.workDir}/cachex ]] || \
              (mkdir -p ${cfg.settings.workDir}/cachex && chown komunix:users ${cfg.settings.workDir}/cachex)

            ${getExe cfg.cachexPackage} ${cfg.settings.workDir}/nfs > ${cfg.settings.workDir}/cachex/index.html
          '';

        systemd.services.caddy = {
          unitConfig.Description = "Caddy";
          serviceConfig.StartLimitInterval = 5;
          serviceConfig.StartLimitBurst = 10;
          serviceConfig.Restart = "always";
          serviceConfig.RestartSec = 10;
          serviceConfig.StandardOutput = null;
          serviceConfig.StandardError = "journal";
          serviceConfig.WorkingDirectory = cfg.settings.workDir;
          serviceConfig.StateDirectory = "cachex";
          serviceConfig.RuntimeDirectory = "cachex";
          serviceConfig.ExecStart = # bash
            ''
              ${getExe cfg.caddyPackage} file-server --root ${cfg.settings.workDir}/cachex --listen ${cfg.settings.listenAddress}:${toString cfg.settings.listenPort}
            '';
          wantedBy = [ "multi-user.target" ];
        };
      };
    };
}
