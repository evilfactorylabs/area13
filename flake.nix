{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";

    # terranix modules
    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Other sources / nix utilities

    # pre-commit-hooks
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    flake-utils.url = "github:numtide/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";
  };

  outputs = { self, nixpkgs, flake-utils, terranix, flake-compat, nix-filter, pre-commit-hooks }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          terraform = pkgs.terraform;
          terraformConfiguration = terranix.lib.terranixConfiguration {
            inherit system;
            modules = [
              # TODO rewrite *.tf to .nix 
              # see https://terranix.org/documentation/terranix-vs-hcl/
            ];
          };
          sources.nix = nix-filter.lib {
            root = ./.;
            include = [
              (nix-filter.lib.matchExt "nix")
            ];
          };
        in
        {
          defaultPackage = terraformConfiguration;

          # nix develop
          devShells.default = pkgs.mkShell {
            inherit (self.checks.${system}.pre-commit-check) shellHook;
            buildInputs = with pkgs;[
              terraform
              terranix.defaultPackage.${system}

              tfsec
              terrascan

              ripgrep
              bat
            ];
          };

          # nix run ".#apply"
          apps.apply = {
            type = "app";
            program = toString (pkgs.writers.writeBash "apply" ''
              if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
              cp ${terraformConfiguration} config.tf.json \
                && ${terraform}/bin/terraform init \
                && ${terraform}/bin/terraform apply
            '');
          };

          # nix run ".#build"
          apps.build = {
            type = "app";
            program = toString (pkgs.writers.writeBash "apply" ''
              if [[ -e config.tf.json ]]; then rm config.tf.json; fi
              cp ${terraformConfiguration} config.tf.json
            '');
          };

          # nix run ".#apply"
          apps.apply = {

            # nix run ".#destroy"
            apps.destroy = {
              type = "app";
              program = toString (pkgs.writers.writeBash "destroy" ''
                if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
                cp ${terraformConfiguration} config.tf.json \
                  && ${terraform}/bin/terraform init \
                  && ${terraform}/bin/terraform destroy
              '');
            };

            # nix flake check
            checks = {
              pre-commit-check = pre-commit-hooks.lib.${system}.run {
                src = ./.;
                hooks = {
                  nixpkgs-fmt.enable = true;
                  terraform-format.enable = true;
                  validate-terraform = {
                    name = "Validate terraform configuration";
                    enable = true;
                    entry = "terraform validate";
                    files = "\\.tf.json$";
                    language = "system";
                    pass_filenames = false;
                  };
                };
              };
            };


            # nix run
            # every run will be generated config.tf.json
            defaultApp = self.apps.${system}.apply;
          });
        }
