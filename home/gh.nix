_:

{
  programs.gh = {
    enable = true;

    settings = {
      git_protocol = "https";
      prompt = "enabled";
      prefer_editor_prompt = "disabled";

      aliases = {
        co = "pr checkout";
      };
    };

    # Credential helper configured in git.nix (avoids duplicate gitconfig sections)
  };
}
