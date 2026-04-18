{ config, ... }:

{
  # Claude reads CLAUDE.md from ~/.claude/
  home.file.".claude/CLAUDE.md".source = ../AGENTS.md;
  programs.claude-code.enable = true;

  # Claude writes runtime state back to settings.json (onboarding flags, MCP
  # additions, etc.), so it can't be a read-only store symlink. Merge declared
  # keys into the live file on each switch instead — runtime scribbles survive,
  # declared keys get re-stamped.
  mergeJsonFiles.claudeSettings = {
    file = "${config.home.homeDirectory}/.claude/settings.json";
    settings = {
      env = {
        CLAUDE_SKIP_FEEDBACK_SURVEY = "1";
        DISABLE_TELEMETRY = "1";
      };
      includeCoAuthoredBy = true;
      permissions = {
        allow = [
          "Bash(git:*)"
          "Bash(gh:*)"
          "Bash(gt:*)"
          "Bash(ruby:*)"
          "Bash(bundle:*)"
          "Bash(gem:*)"
          "Bash(rails:*)"
          "Bash(bin/rails:*)"
          "Bash(cargo:*)"
          "Bash(rustc:*)"
          "Bash(python:*)"
          "Bash(python3:*)"
          "Bash(pip:*)"
          "Bash(uv:*)"
          "Bash(uvx:*)"
          "Bash(npm:*)"
          "Bash(yarn:*)"
          "Bash(nix:*)"
          "Bash(make:*)"
          "Bash(rg:*)"
          "Bash(fd:*)"
          "Bash(fzf:*)"
          "Bash(grep:*)"
          "Bash(find:*)"
          "Bash(command -v:*)"
          "Bash(cat:*)"
          "Bash(head:*)"
          "Bash(tail:*)"
          "Bash(sort:*)"
          "Bash(uniq:*)"
          "Bash(cut:*)"
          "Bash(tr:*)"
          "Bash(sed:*)"
          "Bash(awk:*)"
          "Bash(jq:*)"
          "Bash(yq:*)"
          "Bash(wc:*)"
          "Bash(diff:*)"
          "Bash(tee:*)"
          "Bash(printf:*)"
          "Bash(ls:*)"
          "Bash(tree:*)"
          "Bash(stat:*)"
          "Bash(file:*)"
          "Bash(du:*)"
          "Bash(readlink:*)"
          "Bash(realpath:*)"
          "Bash(dirname:*)"
          "Bash(basename:*)"
          "Bash(mkdir:*)"
          "Bash(touch:*)"
          "Bash(cp:*)"
          "Bash(mv:*)"
          "Bash(ln:*)"
          "Bash(chmod:*)"
          "Bash(tar:*)"
          "Bash(shasum:*)"
          "Bash(date:*)"
          "Bash(uname:*)"
          "Bash(curl:*)"
          "Bash(stow:*)"
          "Bash(shellcheck:*)"
          "Bash(markdownlint-cli2:*)"
          "Read(**)"
          "WebSearch"
          "WebFetch(domain:github.com)"
        ];
        deny = [
          "Bash(sudo:*)"
          "Bash(rm -rf /*)"
          "Bash(rm -rf ~/*)"
          "Bash(rm -rf .)"
          "Bash(chmod 777:*)"
          "Bash(dd:*)"
          "Read(**/.env)"
          "Read(**/.env.*)"
          "Read(**/secrets/**)"
          "Read(**/*.pem)"
          "Read(**/*.key)"
          "Read(**/.ssh/**)"
          "Read(**/.aws/**)"
          "Read(**/.netrc)"
          "Read(**/.config/gh/hosts.yml)"
          "Read(**/.claude/settings.local.json)"
        ];
        ask = [
          "Bash(git push --force:*)"
          "Bash(rm -rf:*)"
          "Bash(pkill:*)"
          "Bash(bash:*)"
          "Bash(fish:*)"
          "Bash(xargs:*)"
        ];
      };
      model = "opus";
      alwaysThinkingEnabled = true;
      skipDangerousModePermissionPrompt = true;
      autoUpdaterStatus = "enabled";
      hasCompletedOnboarding = true;
    };
  };
}
