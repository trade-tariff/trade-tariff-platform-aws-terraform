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
    nixpkgs-ruby = {
      url = "github:bobvanderlinden/nixpkgs-ruby";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, nixpkgs-terraform, nixpkgs-ruby }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          system = system;
          overlays = [ nixpkgs-ruby.overlays.default ];
        };

        rubyVersion = builtins.head (builtins.split "\n" (builtins.readFile ./.ruby-version));
        ruby = pkgs."ruby-${rubyVersion}";

        terraform = nixpkgs-terraform.packages.${system}."1.11";

        lint = pkgs.writeScriptBin "lint" ''
          ${pkgs.pre-commit}/bin/pre-commit run -a
        '';

        clean-terraform = pkgs.writeScriptBin "clean-terraform" ''
          find . -type d -name ".terraform" | xargs -- rm -rf
        '';

        clean = pkgs.writeScriptBin "clean" ''
          clean-terraform && find . -type f -name ".terraform.lock.hcl" -delete
        '';

        init = pkgs.writeScriptBin "init" ''
          clean-terraform

          for m in modules/*; do
            if [ -d $m ]; then
              terraform -chdir=$m init
            fi
          done

          DISABLE_INIT=true terragrunt init --all --provider-cache
        '';

        update-providers = pkgs.writeScriptBin "update-providers" ''clean &&
        init && lint'';
      in
      {
        devShells.default = pkgs.mkShell {
          shellHook = ''
            export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
            export TG_PROVIDER_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
            export TG_PROVIDER_CACHE=1
          '';

          buildInputs = with pkgs; [
            terraform        # For terraform_fmt, terraform_validate
            terragrunt       # For terragrunt-hclfmt
            tflint           # For terraform_tflint
            terraform-docs   # For terraform_docs
            pre-commit       # For running hooks
            trufflehog       # For trufflehog secret scanning
            lint             # Custom lint script
            init             # Custom init script to get all the modules for validation
            clean            # Custom script to clean up .terraform.lock.hcl files and .terraform.lock.hcl
            update-providers # Custom init script to get all the modules for validation
            clean-terraform  # Custom script to clean up .terraform directories
            ruby             # Ruby interpreter for myott lambdas
          ];
        };
      });
}
