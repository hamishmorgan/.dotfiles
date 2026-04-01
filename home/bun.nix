{ pkgs, lib, ... }:

let
  bunGlobalPackages = [
    "opencode-ai"
  ];
in
{
  home.packages = [ pkgs.bun ];

  home.sessionPath = [ "$HOME/.cache/.bun/bin" ];

  home.activation.bunGlobalPackages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.bun}/bin/bun add -g ${lib.concatStringsSep " " bunGlobalPackages}
  '';

  home.shellAliases = {
    npx = "bunx";
    npm = "bun";
  };
}
