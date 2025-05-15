{
  nixConfig = {
    extra-substituters = [
      "https://nixpkgs-terraform.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixpkgs-terraform.cachix.org-1:8Sit092rIdAVENA3ZVeH9hzSiqI/jng6JiCrQ1Dmusw="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-terraform.url = "github:stackbuilders/nixpkgs-terraform";
  };

  outputs = { self, nixpkgs, flake-utils, nixpkgs-terraform }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        terraform = nixpkgs-terraform.packages.${system}."1.11";
        pkgs = import nixpkgs { inherit system; };

        lint = pkgs.writeScriptBin "lint" ''
          ${pkgs.pre-commit}/bin/pre-commit run -a
        '';

        init = pkgs.writeScriptBin "init" ''DISABLE_INIT=true terragrunt init --all'';

        update-providers = pkgs.writeScriptBin "upgrade-providers" ''
          DISABLE_INIT=true terragrunt init --all --upgrade --reconfigure
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            terraform        # For terraform_fmt, terraform_validate
            terragrunt       # For terragrunt-hclfmt
            tflint           # For terraform_tflint
            terraform-docs   # For terraform_docs
            pre-commit       # For running hooks
            trufflehog       # For trufflehog secret scanning
            lint             # Custom lint script
            init             # Custom init script to get all the modules for validation
            update-providers # Custom init script to get all the modules for validation
          ];
        };
      });
}
