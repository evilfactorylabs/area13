with import <nixpkgs> {};

pkgs.mkShell {
  name = "area13";

  buildInputs = [
    terraform
    tfsec
    terrascan
    ripgrep
    bat
  ];
}
