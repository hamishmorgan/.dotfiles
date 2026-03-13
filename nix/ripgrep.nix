{ ... }:

{
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--smart-case"
      "--follow"
      "--hidden"

      # Exclude patterns
      "--glob=!.git/*"
      "--glob=!node_modules/*"
      "--glob=!.venv/*"
      "--glob=!__pycache__/*"
      "--glob=!*.pyc"
      "--glob=!.DS_Store"

      # Output formatting
      "--colors=match:fg:yellow"
      "--colors=match:style:bold"
      "--colors=line:fg:cyan"
      "--colors=path:fg:green"

      # Max columns for long lines
      "--max-columns=150"
      "--max-columns-preview"

      # Sort results
      "--sort=path"
    ];
  };
}
