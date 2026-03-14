{ ... }:

{
  programs.fd = {
    enable = true;
    hidden = true;
    ignores = [
      ".git/"
      "node_modules/"
      ".venv/"
      "__pycache__/"
      ".DS_Store"
    ];
  };
}
