_:

{
  programs.delta = {
    enable = true;
    enableGitIntegration = true;

    options = {
      # Active features (space-separated)
      features = "line-numbers decorations word-diff blame grep";

      # Core
      navigate = true;
      light = false;
      syntax-theme = "Dracula";
      true-color = "always";
      paging = "auto";
      tabs = 4;
      relative-paths = true;
      keep-plus-minus-markers = true;

      # Width & wrapping
      width = "variable";
      wrap-max-lines = "unlimited";

      # Performance
      max-line-length = 3000;

      # Feature: line-numbers
      line-numbers = {
        line-numbers = true;
        line-numbers-left-format = "{nm:>4}┊";
        line-numbers-right-format = "{np:>4}│";
      };

      # Feature: decorations
      decorations = {
        file-style = "bold yellow ul";
        file-decoration-style = "yellow box";
        file-added-label = "[+]";
        file-modified-label = "[~]";
        file-removed-label = "[-]";
        file-renamed-label = "[→]";
        hunk-header-style = "file line-number syntax";
        hunk-header-decoration-style = "blue box";
        commit-style = "bold yellow";
        commit-decoration-style = "bold yellow box ul";
      };

      # Feature: word-diff
      word-diff = {
        word-diff-regex = "\\w+";
        max-line-distance = "0.6";
      };

      # Feature: blame
      blame = {
        blame-code-style = "syntax";
        blame-format = "{author:<15} {commit:<8} {timestamp:<15}";
        blame-separator-format = "│{n:^4}│";
      };

      # Feature: grep
      grep = {
        grep-match-word-style = "bold reverse";
      };

      # Feature: side-by-side (opt-in via DELTA_FEATURES=+side-by-side)
      side-by-side = {
        side-by-side = true;
      };

      # Feature: hyperlinks (opt-in via features)
      hyperlinks = {
        hyperlinks = true;
        hyperlinks-file-link-format = "cursor://file/{path}:{line}";
      };

      # Feature: minimal (opt-in via features)
      minimal = {
        file-decoration-style = "none";
        hunk-header-decoration-style = "none";
        commit-decoration-style = "none";
      };
    };
  };
}
