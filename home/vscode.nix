{
  pkgs,
  ...
}:

{
  programs.vscode = {
    enable = true;
    # vscode-fhs wraps the binary in an FHS env so proprietary extensions
    # with hard-coded /lib64 paths work on NixOS. macOS doesn't need it.
    package = if pkgs.stdenv.isLinux then pkgs.vscode-fhs else pkgs.vscode;
    mutableExtensionsDir = true;
  };

  # settings.json is intentionally user-managed. VS Code writes JSONC
  # (comments, trailing commas) which the mergeJsonFiles jq merger rejects.
}
