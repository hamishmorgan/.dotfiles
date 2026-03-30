{
  description = "Hamish's dotfiles managed with Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      mkHome =
        {
          system,
          username,
          gitEmail,
          dotfilesRelPath ? "git/github.com/hamishmorgan/.dotfiles",
        }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          inherit (pkgs.stdenv) isDarwin;
          homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit
              username
              isDarwin
              gitEmail
              homeDirectory
              ;
            dotfilesPath = "${homeDirectory}/${dotfilesRelPath}";
          };
          modules = [ ./nix/home.nix ];
        };
    in
    {
      # Usage: home-manager switch --flake .#shopify
      homeConfigurations = {
        "shopify" = mkHome {
          system = "aarch64-darwin";
          username = "hamish";
          gitEmail = "hamish.morgan@shopify.com";
          dotfilesRelPath = ".dotfiles";
        };
        "personal" = mkHome {
          system = "x86_64-linux";
          username = "hamish";
          gitEmail = "hamish.morgan@gmail.com";
          dotfilesRelPath = ".dotfiles";
        };
        "odin" = mkHome {
          system = "x86_64-linux";
          username = "hamish";
          gitEmail = "hamish.morgan@gmail.com";
        };
      };

      # nix develop
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              # Linting
              shellcheck
              fish # fish --no-execute for syntax checking
              markdownlint-cli2

              # Testing
              bats

              # Security
              gitleaks

              # Utilities
              python3

              # Nix linting + formatting
              deadnix
              statix
              nixfmt
            ];
          };
        }
      );

      # Allow `nix fmt`
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
