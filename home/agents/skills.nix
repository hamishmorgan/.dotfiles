{ pkgs, lib, ... }:

{
  home = {
    packages = [ pkgs.nodejs ];

    activation.bunInstallSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.bun}/bin/bun add -g --no-summary skills
    '';
  };
}
