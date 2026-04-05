{
  description = "Hamish's dotfiles managed with Home Manager";

  nixConfig = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    {
      self,
      nixpkgs-unstable,
      nixpkgs-stable,
      home-manager,
      noctalia,
      ...
    }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs-unstable.lib.genAttrs supportedSystems;

      mkHome =
        {
          system,
          username,
          userEmail,
          dotfilesRelPath ? "git/github.com/hamishmorgan/.dotfiles",
          enableOllama ? false,
        }:
        let
          pkgs = nixpkgs-unstable.legacyPackages.${system};
          inherit (pkgs.stdenv) isDarwin;
          homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit
              username
              isDarwin
              userEmail
              homeDirectory
              enableOllama
              ;
            dotfilesPath = "${homeDirectory}/${dotfilesRelPath}";
          };
          modules = [
            ./lib/merge-json.nix
            ./home
          ];
        };
    in
    {
      # Usage: home-manager switch --flake .#shopify
      homeConfigurations = {
        "shopify" = mkHome {
          system = "aarch64-darwin";
          username = "hamish";
          userEmail = "hamish.morgan@shopify.com";
          dotfilesRelPath = ".dotfiles";
          enableOllama = false;
        };
        "personal" = mkHome {
          system = "x86_64-linux";
          username = "hamish";
          userEmail = "hamish.morgan@gmail.com";
          dotfilesRelPath = ".dotfiles";
          enableOllama = false;
        };
        "odin" = mkHome {
          system = "x86_64-linux";
          username = "hamish";
          userEmail = "hamish.morgan@gmail.com";
          enableOllama = false;
        };
      };

      # nix develop
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs-unstable.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            shellHook = ''
              git config --local core.hooksPath .githooks
            '';
            packages = with pkgs; [
              # Linting
              shellcheck
              shfmt
              fish # fish --no-execute + fish_indent
              markdownlint-cli2
              yamllint
              stylua
              taplo

              # Testing
              bats

              # Security
              gitleaks

              # Utilities
              bun
              python3

              # Nix linting + formatting
              deadnix
              statix
              nixfmt
            ];
          };
        }
      );

      # NixOS system configurations
      nixosConfigurations.odin = import ./hosts/odin { inherit self nixpkgs-stable noctalia; };

      # Allow `nix fmt`
      formatter = forAllSystems (system: nixpkgs-unstable.legacyPackages.${system}.nixfmt);
    };
}
