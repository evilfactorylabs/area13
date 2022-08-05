with import <nixpkgs> {};

pkgs.mkShell {
  name = "evilfactorylabs-dns";

  buildInputs = [
    terraform
    tfsec
    terrascan
    ripgrep
    bat
  ];
}
