{ isDarwin, lib, ... }:

let
  readFish = file: builtins.readFile ./${file};
in
{
  programs.fish = {
    enable = true;

    # Fish abbreviations expand inline (visible before executing), richer than
    # the shared aliases in aliases.nix which also apply here harmlessly.
    shellAbbrs = {
      # Git (richer set than aliases — fish abbreviations expand inline)
      g = "git";
      ga = "git add";
      gaa = "git add --all";
      gap = "git add --patch";
      gc = "git commit";
      gcm = "git commit -m";
      gca = "git commit --amend";
      gcan = "git commit --amend --no-edit";
      gp = "git push";
      gpf = "git push --force-with-lease";
      gl = "git pull";
      gf = "git fetch";
      gfa = "git fetch --all --prune";
      gd = "git diff";
      gds = "git diff --staged";
      gs = "git status";
      gss = "git status --short";
      gco = "git checkout";
      gcb = "git checkout -b";
      gb = "git branch";
      gba = "git branch --all";
      gbd = "git branch --delete";
      gbD = "git branch --delete --force";
      glog = "git log --oneline --graph --decorate";
      gloga = "git log --oneline --graph --decorate --all";
      gsh = "git show";
      gst = "git stash";
      gstp = "git stash pop";
      gstl = "git stash list";
      gr = "git reset";
      grh = "git reset --hard";
      grs = "git reset --soft";
      grb = "git rebase";
      grbi = "git rebase --interactive";
      grbc = "git rebase --continue";
      grba = "git rebase --abort";
      gcp = "git cherry-pick";
      gcpc = "git cherry-pick --continue";
      gcpa = "git cherry-pick --abort";
      gwt = "git worktree";
      gwta = "git worktree add";
      gwtl = "git worktree list";
      gwtr = "git worktree remove";
      gwtp = "git worktree prune";

      # Graphite
      gts = "gt stack";
      gtc = "gt create";
      gtsub = "gt submit --no-interactive";
      gtsy = "gt sync";
      gtre = "gt restack";
      gtco = "gt checkout";
      gtd = "gt down";
      gtu = "gt up";

      # Navigation
      "....." = "cd ../../../..";

      # Common
      mkd = "mkdir -p";
      dotcd = "cd ~/.dotfiles";

      # Docker
      dk = "docker";
      dkps = "docker ps";
      dkpsa = "docker ps -a";
      dki = "docker images";
      dkrm = "docker rm";
      dkrmi = "docker rmi";
    };

    # Typed functions (each becomes ~/.config/fish/functions/NAME.fish)
    functions = {
      # Editor functions
      e = {
        description = "Edit file with EDITOR";
        body = ''
          set -l editor "$EDITOR"
          if test -z "$editor"
              if command -q nvim; set editor nvim
              else if command -q vim; set editor vim
              else; set editor vi
              end
          end
          set -l editor_cmd (string split " " -- "$editor")[1]
          if not command -q "$editor_cmd"
              echo "Error: Editor not found: $editor_cmd" >&2
              return 1
          end
          eval "$editor" $argv
        '';
      };
      v = {
        description = "Edit file with EDITOR";
        body = "e $argv";
      };

      # Git helpers
      gclean = {
        description = "Delete merged git branches (interactive)";
        body = ''
          if not git rev-parse --git-dir >/dev/null 2>&1
              echo "Not in a git repository"
              return 1
          end
          set -l merged_branches (git branch --merged |
              grep -v "^\*" |
              grep -v "main\|master\|develop" |
              string trim)
          if test (count $merged_branches) -eq 0
              echo "No merged branches to delete"
              return 0
          end
          echo "Merged branches that can be deleted:"
          for branch in $merged_branches
              echo "  - $branch"
          end
          read -l -P "Delete these branches? [y/N] " confirm
          if test "$confirm" = y -o "$confirm" = Y
              for branch in $merged_branches
                  git branch -d $branch
                  and echo "Deleted: $branch"
              end
          else
              echo Cancelled
          end
        '';
      };
      gundo = {
        description = "Undo last git commit (keep changes)";
        body = "git reset --soft HEAD~1";
      };
      gunwip = {
        description = "Undo WIP commit";
        body = ''
          set -l last_commit (git log -1 --pretty=%B)
          if string match -q "WIP:*" "$last_commit"
              git reset HEAD~1
              echo "Undone WIP commit: $last_commit"
          else
              echo "Last commit is not a WIP commit"
              echo "Last commit: $last_commit"
              return 1
          end
        '';
      };
      gwip = {
        description = "Git work in progress - quick commit";
        body = ''
          git add --all
          and git commit -m "WIP: work in progress" --no-verify
        '';
      };

      # Search
      rgf = {
        description = "Search code with ripgrep and fzf, open in editor";
        body = ''
          if test (count $argv) -eq 0
              echo "Usage: rgf <search-term> [rg-options]"
              return 1
          end
          set -l result (rg --color=always --line-number --no-heading --smart-case $argv |
              fzf --ansi \
                  --color 'hl:-1:underline,hl+:-1:underline:reverse' \
                  --delimiter ':' \
                  --preview 'bat --color=always {1} --highlight-line {2}' \
                  --preview-window 'up,60%,border-bottom,+{2}+3/3,~3')
          or return
          if test -n "$result"
              set -l file (echo $result | cut -d: -f1)
              set -l line (echo $result | cut -d: -f2)
              if test -n "$EDITOR"
                  eval $EDITOR "+$line" "$file"
              else if command -q nvim
                  nvim "+$line" "$file"
              else if command -q vim
                  vim "+$line" "$file"
              end
          end
        '';
      };

      # Command logging
      fish_postexec = {
        onEvent = "fish_postexec";
        description = "Log every command for DX analysis";
        body = ''
          set -l exit_code $status
          set -l ts (date -u +"%Y-%m-%dT%H:%M:%SZ")
          set -l cmd_escaped (printf '%s' $argv[1] | jq -Rs .)
          set -l cwd_escaped (printf '%s' $PWD | jq -Rs .)
          echo "{\"ts\":\"$ts\",\"exit\":$exit_code,\"ms\":$CMD_DURATION,\"cwd\":$cwd_escaped,\"sid\":$fish_pid,\"cmd\":$cmd_escaped}" >> ~/.cmdlog.jsonl
        '';
      };

      # Prompt
      fish_prompt = {
        description = "Write out the prompt";
        body = builtins.readFile ./prompt.fish;
      };
    };

    # Nix environment (runs for all shells, before interactive init)
    shellInit = readFish "nix-env.fish";

    loginShellInit = lib.optionalString isDarwin ''
      if test -x /opt/homebrew/bin/brew
          eval (/opt/homebrew/bin/brew shellenv)
      else if test -x /usr/local/bin/brew
          eval (/usr/local/bin/brew shellenv)
      end
    '';

    interactiveShellInit = ''
      set -g fish_greeting

      # Process management (conditional on tool availability)
      command -q procs; and abbr -a ps procs
      command -q btop; and abbr -a top btop
      or command -q htop; and abbr -a top htop

      ${readFish "theme.fish"}
      ${readFish "editor.fish"}
      ${readFish "rust.fish"}
      ${readFish "uv.fish"}
      ${readFish "graphite.fish"}
      ${readFish "shopify.fish"}
    '';
  };
}
