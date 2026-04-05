{
  pkgs,
  lib,
  enableOllama ? true,
  ...
}:

{
  home.packages = lib.optionals enableOllama [
    (if pkgs.stdenv.isLinux then pkgs.ollama-cuda else pkgs.ollama)
  ];
}
