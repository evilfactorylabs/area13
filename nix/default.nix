{ self, inputs, ... }:

{
  flake.nixosConfigurations.komunix-vm2 = self.nixosConfigurations.komunix.extend {
    modules = [
      (
        { }:
        {
          services.nginx.enable = true;
        }
      )
    ];
  };
  flake.nixosConfigurations.komunix = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      "${inputs.nixpkgs}/nixos/modules/profiles/macos-builder.nix"
      self.nixosModules.common

      {
        users.users.root.openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDKvi3Co5fB1dSU2Qs1sR6LwdB1hM6HCyIWfXsC0wgz1pmeFlje24SzPCxDtsVMq28fDpEBsXPqKSZbUIyBtHRnpIc72Z8IV0KNtBjbKQTfHLTiDu43e+VLuAdFE7u2Wf5KPQIQ52r/jr9P7UKU2GKwV016OzrRiaZjm+gixmd8YRfidzG1bsL5fbKBjxCIUROdVpW5kNNtPZHpeuHCkZ7341USC6V2qnp1BNHIoHLjRYosV82apOxN/AWY/tMN2jlVQ/gKIUHbxXoILsG+XRFCen5TSSearx54KxifI1aIWbxVVmmYNuLXGWnVumaH6U7ARpz2cEXQB9z2lvJGYmod8qfloVdjXESu8OFe4RT+nj0JUQs7pMhiN6K1AsMQiyFc0ZmU2UNx4JcHre5STnSKUHUCx4zzoToFvIQRBTB3HePHy74FcXWaYDAN/6YF3JEA203nyYL4o5m/KhSXNkcT3H+r3IAqKnl7J7obsvNowwa1UB2NxVmq0VXXR8uZlT0="
          "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBHnjecqMe2lrGzAvQ2VQRTXhjZ5q1tONgme+2/97Z3VSXdY0i2bEH3qGEIC7uMyWUfmLystXxqP0u6/Xspmm0Ck="
        ];
        users.users.komunix = {
          home = "/home/komunix";
          createHome = true;
          isNormalUser = true;
          extraGroups = [ "wheel" ];
          openssh.authorizedKeys.keys = [
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDKvi3Co5fB1dSU2Qs1sR6LwdB1hM6HCyIWfXsC0wgz1pmeFlje24SzPCxDtsVMq28fDpEBsXPqKSZbUIyBtHRnpIc72Z8IV0KNtBjbKQTfHLTiDu43e+VLuAdFE7u2Wf5KPQIQ52r/jr9P7UKU2GKwV016OzrRiaZjm+gixmd8YRfidzG1bsL5fbKBjxCIUROdVpW5kNNtPZHpeuHCkZ7341USC6V2qnp1BNHIoHLjRYosV82apOxN/AWY/tMN2jlVQ/gKIUHbxXoILsG+XRFCen5TSSearx54KxifI1aIWbxVVmmYNuLXGWnVumaH6U7ARpz2cEXQB9z2lvJGYmod8qfloVdjXESu8OFe4RT+nj0JUQs7pMhiN6K1AsMQiyFc0ZmU2UNx4JcHre5STnSKUHUCx4zzoToFvIQRBTB3HePHy74FcXWaYDAN/6YF3JEA203nyYL4o5m/KhSXNkcT3H+r3IAqKnl7J7obsvNowwa1UB2NxVmq0VXXR8uZlT0="
            "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBHnjecqMe2lrGzAvQ2VQRTXhjZ5q1tONgme+2/97Z3VSXdY0i2bEH3qGEIC7uMyWUfmLystXxqP0u6/Xspmm0Ck="
          ];
        };
      }

      (
        { pkgs, lib, ... }:
        let
          genCachex = pkgs.writeShellApplication {
            name = "gen-cachex";
            runtimeInputs = with pkgs; [
              coreutils
              gnused
              envsubst
            ];
            text = ''
              TIMESTAMP=$(date +%s)
              USAGE=$(df -h /home/komunix/nfs/nix-cache | tail -n1 || 0)
              TOTAL_CACHE=$(find /home/komunix/nfs/nix-cache -type f | wc -l)
              NICE=$(du -sh /home/komunix/nfs/nix-cache)

              export TIMESTAMP
              export USAGE
              export TOTAL_CACHE
              export NICE
              envsubst < ${./cache.html.tpl}
            '';
          };
        in
        {
          system.stateVersion = "24.05";
          environment.systemPackages = [ pkgs.caddy ];
          system.activationScripts.createDir =
            lib.mkBefore # bash
              ''
                [[ -d /home/komunix/cachex ]] || \
                  (mkdir -p /home/komunix/cachex && chown komunix:users /home/komunix/cachex)

                [[ -d /home/komunix/nfs ]] || \
                  (mount -t nfs -O rw,username=komunix,uid=1030,gid=100 100.121.185.1:/volume2/komunix /home/komunix/nfs)

                ${lib.getExe genCachex} > /home/komunix/cachex/index.html
              '';

          services.cron.enable = true;
          services.cron.systemCronJobs = [
            "* * * * * cachex ${lib.getExe genCachex} > /home/komunix/cachex/index.html"
          ];
          systemd.services.caddy = {
            unitConfig.Description = "Caddy";
            serviceConfig.StartLimitIntervalSec = 5;
            serviceConfig.StartLimitBurst = 10;
            serviceConfig.Restart = "always";
            serviceConfig.RestartSec = 10;
            serviceConfig.StandardOutput = null;
            serviceConfig.StandardError = "journal";
            serviceConfig.WorkingDirectory = "/home/komunix";
            serviceConfig.StateDirectory = "cachex";
            serviceConfig.RuntimeDirectory = "cachex";
            serviceConfig.ExecStart = # bash
              ''
                ${lib.getExe pkgs.caddy} file-server --root /home/komunix/cachex --listen 127.0.0.1:2022
              '';
            wantedBy = [ "multi-user.target" ];
          };
        }
      )
    ];
  };

  flake.nixosModules.common = {
    nixpkgs.config.allowUnfree = true;
    nix.settings.auto-optimise-store = true;
    nix.settings.fallback = true;
    nix.settings.experimental-features = [
      "flakes"
      "nix-command"
    ];
  };
}
