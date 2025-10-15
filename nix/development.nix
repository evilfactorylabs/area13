{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      system,
      self',
      ...
    }:
    {
      checks.pre-commit-check = inputs.git-hooks.lib.${system}.run {
        src = ./../.;
        hooks = {
          actionlint.enable = true;
          nixfmt-rfc-style.enable = true;
          deadnix.enable = true;
        };
      };

      formatter =
        let
          gitHookConfig = self'.checks.pre-commit-check.config;
        in
        pkgs.writeShellScriptBin "format-all" ''
          ${pkgs.lib.getExe gitHookConfig.package} run --all-files --config ${gitHookConfig.configFile}
        '';

      devShells.default =
        let
          gitHook = self'.checks.pre-commit-check;
        in
        pkgs.mkShell {
          shellHook = gitHook.shellHook;
          buildInputs =
            with pkgs;
            [
              terraform
              tfsec
              terrascan
              ripgrep
              bat
              self'.formatter
            ]
            ++ gitHook.enabledPackages;
        };
    };
}
