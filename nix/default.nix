{ inputs, ... }:

{
  imports = [
    inputs.ez-configs.flakeModule
    ./development.nix
  ];

  perSystem =
    { system, ... }:
    {
      _module.args = {
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      };
    };

  ezConfigs = {
    root = ./.;
    /**
      We can pass global arguments to all configurations and modules here.

      example:

      file under `nixos/configurations/my-config.nix` wants to use `inputs.something`. so we need to pass `inputs` to `globalArgs`.
      ```nix
      { inputs, self, ... }:
      {
        environment.systemPackages = with pkgs; [
          inputs.something
        ];
      }
      ```
    */
    globalArgs = {
      inherit inputs;

      maintainers = rec {
        all = import ./maintainers.nix;

        getMaintainerKeysByRole =
          with inputs.nixpkgs.lib;
          role:
          pipe all [
            attrValues
            (filter (maintainer: (maintainer.role or "") == role))
            (map (maintainer: maintainer.sshKeys))
            flatten
          ];
      };
    };

    /**
      Setup layout with ez-configs

      All files under `nixos/configurations` will be treated as NixOS configurations.
      All files under `nixos/modules` will be treated as NixOS modules.'
    */
    nixos.modulesDirectory = ./modules/nixos;
    nixos.configurationsDirectory = ./configurations/nixos;
  };

}
