{ pkgs, ... }:

{
  home.packages = [
    (if pkgs.stdenv.isLinux then pkgs.ollama-cuda else pkgs.ollama)
  ];
}
