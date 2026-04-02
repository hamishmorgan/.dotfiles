{ pkgs, lib, ... }:

{
  home.packages = [
    pkgs.nodejs
  ];

  home.activation.bunInstallOpencode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.bun}/bin/bun add -g --no-summary opencode-ai
  '';
}
