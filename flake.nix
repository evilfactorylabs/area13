{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";

    # terranix modules
    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Other sources / nix utilities
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, terranix, flake-compat }:
    flake-utils.lib.eachDefaultSystem (system:
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
      in
      {
        defaultPackage = terraformConfiguration;

        # nix develop
        devShell = pkgs.mkShell {
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

        # nix run
        # every run will be generated config.tf.json
        defaultApp = self.apps.${system}.apply;
      });
}
