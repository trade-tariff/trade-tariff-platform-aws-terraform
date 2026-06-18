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
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
    };
    nixpkgs-terraform.url = "github:stackbuilders/nixpkgs-terraform";
    nixpkgs-ruby = {
      url = "github:bobvanderlinden/nixpkgs-ruby";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      pre-commit-hooks,
      nixpkgs-terraform,
      nixpkgs-ruby,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          system = system;
          overlays = [ nixpkgs-ruby.overlays.default ];
        };

        rubyVersion = builtins.head (builtins.split "\n" (builtins.readFile ./.ruby-version));
        ruby = pkgs."ruby-${rubyVersion}";

        terraform = nixpkgs-terraform.packages.${system}."terraform-1.13.4";

        lint = pkgs.writeShellScriptBin "lint" ''
          pre-commit run -a
        '';

        clean-terraform = pkgs.writeShellScriptBin "clean-terraform" ''
          find . -type d -name ".terraform" | xargs -- rm -rf
        '';

        clean = pkgs.writeShellScriptBin "clean" ''
          clean-terraform && find . -type f -name ".terraform.lock.hcl" -delete && find . -type f -name "backend.tf" -delete
        '';

        init = pkgs.writeShellScriptBin "init" ''
          clean-terraform

          for m in modules/*; do
            if [ -d $m ]; then
              terraform -chdir=$m init
            fi
          done

          DISABLE_INIT=true terragrunt init --all --provider-cache
        '';

        update-providers = pkgs.writeShellScriptBin "update-providers" "clean && init && lint";

        preCommitCheck = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          configPath = ".pre-commit-config-nix.yaml";
          default_stages = [ "pre-commit" ];
          hooks = {
            actionlint = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            check-merge-conflicts = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            check-yaml = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            end-of-file-fixer = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            terraform-format = {
              enable = true;
              package = terraform;
              stages = [ "pre-commit" ];
            };
            tflint = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            terragrunt-hcl-fmt = {
              enable = true;
              name = "terragrunt-hcl-fmt";
              entry = "${pkgs.terragrunt}/bin/terragrunt hcl fmt";
              files = "\\.hcl$";
              stages = [ "pre-commit" ];
            };
            trim-trailing-whitespace = {
              enable = true;
              stages = [ "pre-commit" ];
            };
            trufflehog = {
              enable = true;
              stages = [
                "pre-commit"
                "pre-push"
              ];
            };
          };
        };
      in
      {
        devShells.default = pkgs.mkShell {
          shellHook = ''
            export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
            export TG_PROVIDER_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
            export TG_PROVIDER_CACHE=1
            ${preCommitCheck.shellHook}
            export PATH=${pkgs.writeShellScriptBin "pre-commit" ''
              set -euo pipefail

              has_config=false
              for arg in "$@"; do
                case "$arg" in
                  -c|--config|--config=*)
                    has_config=true
                    ;;
                esac
              done

              if [ "$has_config" = true ]; then
                exec ${preCommitCheck.config.package}/bin/pre-commit "$@"
              fi

              if [ "''${1:-}" = "run" ]; then
                shift
                exec ${preCommitCheck.config.package}/bin/pre-commit run --config .pre-commit-config-nix.yaml "$@"
              fi

              exec ${preCommitCheck.config.package}/bin/pre-commit "$@"
            ''}/bin:$PATH
          '';

          buildInputs =
            preCommitCheck.enabledPackages
            ++ (with pkgs; [
              terraform
              terragrunt
              lint # Custom lint script
              init # Custom init script to get all the modules for validation
              clean-terraform # Custom script to clean up .terraform directories
              clean # Custom script to clean up .terraform.lock.hcl files and .terraform.lock.hcl
              update-providers # Custom init script to get all the modules for validation
              ruby # Ruby interpreter for myott lambdas
            ]);
        };
      }
    );
}
