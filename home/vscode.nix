{
  config,
  pkgs,
  ...
}:

let
  userDir =
    if pkgs.stdenv.isDarwin then
      "${config.home.homeDirectory}/Library/Application Support/Code/User"
    else
      "${config.xdg.configHome}/Code/User";
in
{
  programs.vscode = {
    enable = true;
    # vscode-fhs wraps the binary in an FHS env so proprietary extensions
    # with hard-coded /lib64 paths work on NixOS. macOS doesn't need it.
    package = if pkgs.stdenv.isLinux then pkgs.vscode-fhs else pkgs.vscode;
    mutableExtensionsDir = true;
  };

  # VS Code writes back to settings.json whenever the user toggles a UI option
  # (theme, sync, etc.), so it can't be a read-only store symlink. Merge
  # declared keys into the live file on each switch — runtime scribbles survive,
  # declared keys get re-stamped.
  mergeJsonFiles.vscodeSettings = {
    file = "${userDir}/settings.json";
    settings = {
      # Nix owns the binary; VS Code's own updater can't touch /nix/store.
      "update.mode" = "none";
      "telemetry.telemetryLevel" = "off";
    };
  };
}
