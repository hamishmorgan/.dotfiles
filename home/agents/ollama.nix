{
  pkgs,
  lib,
  enableOllama ? false,
  ...
}:

{
  home.packages = lib.optionals enableOllama [
    (if pkgs.stdenv.isLinux then pkgs.ollama-cuda else pkgs.ollama)
  ];
}
