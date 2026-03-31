_:

{
  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        charset = "utf-8";
        end_of_line = "lf";
        insert_final_newline = true;
        trim_trailing_whitespace = true;
      };
      "*.{sh,bash,zsh,yml,yaml,json,nix,toml}" = {
        indent_style = "space";
        indent_size = 2;
      };
      "*.py" = {
        indent_style = "space";
        indent_size = 4;
      };
      "Makefile" = {
        indent_style = "tab";
      };
      "*.md" = {
        trim_trailing_whitespace = false;
      };
      "*.fish" = {
        indent_style = "space";
        indent_size = 4;
      };
      "*.lua" = {
        indent_style = "space";
        indent_size = 2;
      };
      "*.go" = {
        indent_style = "tab";
      };
      "*.rb" = {
        indent_style = "space";
        indent_size = 2;
      };
      "*.{js,ts,jsx,tsx}" = {
        indent_style = "space";
        indent_size = 2;
      };
    };
  };

  # Readline configuration (bash, python REPL, etc.)
  home.file.".inputrc".source = ./inputrc;
}
