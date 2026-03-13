{ config, lib, pkgs, ... }:

{
  programs.git = {
    enable = true;
    package = pkgs.git;

    # User info configured per-machine in ~/.gitconfig.local
    # (included via settings.include below)

    lfs.enable = true;

    ignores = [
      # Linux
      "*~"
      ".fuse_hidden*"
      ".directory"
      ".Trash-*"
      ".nfs*"

      # macOS
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      "._*"
      ".DocumentRevisions-V100"
      ".fseventsd"
      ".Spotlight-V100"
      ".TemporaryItems"
      ".Trashes"
      ".VolumeIcon.icns"
      ".com.apple.timemachine.donotpresent"
      ".AppleDB"
      ".AppleDesktop"
      "Network Trash Folder"
      "Temporary Items"
      ".apdisk"

      # Windows
      "Thumbs.db"
      "Thumbs.db:encryptable"
      "ehthumbs.db"
      "ehthumbs_vista.db"
      "*.stackdump"
      "[Dd]esktop.ini"
      "$RECYCLE.BIN/"
      "*.cab"
      "*.msi"
      "*.msix"
      "*.msm"
      "*.msp"
      "*.lnk"
    ];

    attributes = [
      "*.tar diff=tar"
      "*.tar.bz2 diff=tar-bz2"
      "*.tar.gz diff=tar-gz"
      "*.tar.xz diff=tar-xz"
      "*.bz2 diff=bz2"
      "*.gz diff=gz"
      "*.zip diff=zip"
      "*.xz diff=xz"
      "*.odf diff=odf"
      "*.odt diff=odf"
      "*.odp diff=odf"
      "*.pdf diff=pdf"
      "*.exe diff=bin"
      "*.png diff=bin"
      "*.jpg diff=bin"
    ];

    settings = {
      alias = {
        # Basic shortcuts
        st = "status";
        ci = "commit";
        co = "checkout";
        br = "branch";
        sw = "switch";
        rs = "restore";
        rb = "rebase";

        # Status and information
        s = "status -s";
        short = "status --short";
        untracked = "ls-files --others --exclude-standard";
        last = "log -1 HEAD";
        who = "blame";
        when = "log --pretty=format:\"%h %ad %s\" --date=short --author";

        # Log formats
        lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
        lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
        ll = "!git --no-pager log --graph --all --decorate --pretty=format:'%C(auto)%h%d  %ad %C(red bold)(%ar%C(red bold))%Creset  %Creset%C(magenta)%an %Creset<%ae>  %C(white bold)%<(80,trunc)%s' --date=iso";
        l = "!git --no-pager log -n 40 --graph --pretty=format:'%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(blue bold)<%an>%Creset'";
        lg = "log --oneline --decorate --graph --all";
        lgp = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";

        # Branch and remote management
        tags = "tag -l";
        branches = "branch -av";
        remotes = "remote -v";
        new = "!f() { git checkout -b $1; }; f";
        del = "branch -D";
        cleanup = "!git branch --merged | grep -v '\\*\\|main\\|master' | xargs -n 1 git branch -d";
        dm = "!git branch --merged | grep -v '\\*' | xargs -n 1 git branch -d";

        # Commit operations
        amend = "commit --amend --reuse-message=HEAD";
        commend = "commit --amend --no-edit";
        fix = "commit --fixup";
        ac = "!git add . && git commend";
        uncommit = "reset --soft HEAD~1";
        undo = "reset --hard HEAD~1";
        unstage = "reset HEAD --";

        # Diff and comparison
        diffc = "diff --cached";
        diffw = "diff --word-diff";
        diffp = "diff --patience";

        # Push and pull
        forcepush = "push --force-with-lease";
        visual = "!zed";
      };

      core = {
        editor = "zed --wait";
        eol = "native";
        autocrlf = "input";
        safecrlf = true;
        ignorecase = false;
        trustctime = false;
        precomposeunicode = false;
      };

      color = {
        ui = "auto";
        branch = {
          current = "yellow reverse";
          local = "yellow";
          remote = "green";
        };
        diff = {
          meta = "yellow bold";
          frag = "magenta bold";
          old = "red";
          new = "green";
        };
        status = {
          added = "yellow";
          changed = "green";
          untracked = "cyan";
        };
      };

      diff = {
        renames = "copies";
        algorithm = "patience";
        colorMoved = "default";
        colorMovedWS = "ignore-all-space";
      };

      apply.whitespace = "fix";

      push = {
        default = "current";
        autoSetupRemote = true;
      };

      pull.ff = "only";
      init.defaultBranch = "main";
      submodule.recurse = true;

      rerere = {
        enabled = true;
        autoupdate = true;
      };

      branch.autosetuprebase = "always";

      merge = {
        tool = "vimdiff";
        conflictstyle = "zdiff3";
      };

      rebase = {
        autosquash = true;
        autostash = true;
      };

      commit = {
        gpgsign = true;
        template = "~/.config/git/message";
      };

      credential = {
        "https://github.com" = {
          helper = [
            ""
            "!/usr/bin/env gh auth git-credential"
          ];
        };
        "https://gist.github.com" = {
          helper = [
            ""
            "!/usr/bin/env gh auth git-credential"
          ];
        };
      };

      # Textconv for binary diffs
      "diff \"zip\"" = { textconv = "unzip -p"; binary = true; };
      "diff \"gz\"" = { textconv = "sh -c 'command -v gzcat >/dev/null 2>&1 && gzcat \"$@\" || cat' sh"; binary = true; };
      "diff \"bz2\"" = { textconv = "sh -c 'command -v bzcat >/dev/null 2>&1 && bzcat \"$@\" || cat' sh"; binary = true; };
      "diff \"xz\"" = { textconv = "sh -c 'command -v xzcat >/dev/null 2>&1 && xzcat \"$@\" || cat' sh"; binary = true; };
      "diff \"tar\"" = { textconv = "tar -O -xf"; binary = true; };
      "diff \"tar-bz2\"" = { textconv = "sh -c 'command -v bzcat >/dev/null 2>&1 && tar -O -xjf \"$@\" || cat' sh"; binary = true; };
      "diff \"tar-gz\"" = { textconv = "tar -O -xzf"; binary = true; };
      "diff \"tar-xz\"" = { textconv = "sh -c 'command -v xzcat >/dev/null 2>&1 && tar -O -xJf \"$@\" || cat' sh"; binary = true; };
      "diff \"odf\"".textconv = "sh -c 'command -v odt2txt >/dev/null 2>&1 && odt2txt \"$@\" || cat' sh";
      "diff \"pdf\"".textconv = "sh -c 'command -v pdfinfo >/dev/null 2>&1 && pdfinfo \"$@\" || cat' sh";
      "diff \"bin\"".textconv = "hexdump -v -C";

      # Machine-specific overrides
      include.path = "~/.gitconfig.local";
    };
  };

  # Commit message template — not supported by programs.git directly
  xdg.configFile."git/message".text = ''
    # Summary (imperative, 50 chars max)
    #
    # Why this change is needed
    #
    # Additional context or implementation notes
    #
    # Refs: #123

    # Guidelines:
    # - Use imperative mood: "add" not "added" or "adds"
    # - Keep first line under 50 characters
    # - Separate subject from body with blank line
    # - Wrap body at 72 characters
    # - Focus on why, not what (code shows what)
    # - Reference issues/PRs: "fixes #123", "closes #456", or "(#123)"
    # - Breaking changes: Explain impact in body
    # - Co-authored-by: Name <email> (for pair programming)
    # - AI commits: Use --author="Agent Name <agent@noreply.local>"
    #
    # Examples:
    # Add disk space cleanup utility (#106)
    # Fix health check validation after packages/ migration (#99)
    # Remove backups/.gitkeep in favor of dynamic directory creation
  '';

  # Delta config — separate file, user opts in via .gitconfig.local
  xdg.configFile."git/delta".source = ../packages/git/.config/git/delta;
}
