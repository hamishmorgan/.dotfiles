{
  description = "Hamish's dotfiles managed with Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      mkHome = { system, username }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          isDarwin = pkgs.stdenv.isDarwin;
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit username;
            homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
          };
          modules = [ ./nix/home.nix ];
        };
    in
    {
      # Usage: home-manager switch --flake .#hamish
      # Add new machines/users as needed
      # Usage: home-manager switch --flake .#work
      homeConfigurations = {
        "work" = mkHome { system = "aarch64-darwin"; username = "hamish"; };
        # "personal" = mkHome { system = "x86_64-linux"; username = "hamish"; };
      };

      # Allow `nix fmt`
      formatter = forAllSystems (system:
        nixpkgs.legacyPackages.${system}.nixpkgs-fmt
      );
    };
}
