{ lib, isDarwin, ... }:

{
  programs.zed-editor = {
    enable = isDarwin;
    mutableUserSettings = true;

    extensions = [
      "catppuccin"
      "material-icon-theme"
      "nix"
      "toml"
      "ruby"
      "fish"
    ];

    userSettings = {
      # Editing
      autosave = "on_focus_change";
      format_on_save = "on";
      auto_indent_on_paste = true;
      soft_wrap = "editor_width";
      show_whitespaces = "boundary";
      cursor_blink = false;
      vertical_scroll_margin = 5;

      # Visual guides
      wrap_guides = [ 80 120 ];
      indent_guides = {
        enabled = true;
        coloring = "indent_aware";
      };

      # Search
      use_smartcase_search = true;

      # Session
      restore_on_startup = "last_session";

      # Git
      git = {
        inline_blame = {
          enabled = true;
          delay_ms = 500;
        };
        git_gutter = "tracked_files";
      };

      # Completion & hints
      show_completion_documentation = true;
      inlay_hints = {
        enabled = true;
        show_type_hints = true;
        show_parameter_hints = false;
      };

      # AI / Agent (model and MCP servers configured per-machine via Zed UI)
      edit_predictions.mode = "subtle";
      agent = {
        tool_permissions.default = "allow";
        play_sound_when_agent_done = true;
        notify_when_agent_waiting = "all_screens";
      };

      # Panels & UI
      outline_panel.dock = "left";
      project_panel = {
        hide_root = false;
        entry_spacing = "comfortable";
      };
      active_pane_modifiers = {
        border_size = 2.0;
        inactive_opacity = 0.7;
      };
      bottom_dock_layout = "contained";
      preview_tabs.enable_preview_from_file_finder = true;
      tabs = {
        show_diagnostics = "off";
        file_icons = true;
        git_status = true;
      };
      title_bar = {
        show_menus = false;
        show_branch_icon = true;
      };
      icon_theme = {
        mode = "system";
        light = "Zed (Default)";
        dark = "Material Icon Theme";
      };
      minimap.show = "auto";

      # Telemetry
      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      # Terminal
      terminal = {
        toolbar.breadcrumbs = true;
        dock = "right";
        max_scroll_history_lines = 100000;
      };

      # Fonts & theme
      buffer_font_family = "JetBrainsMono Nerd Font Mono";
      buffer_font_fallbacks = [ "Menlo" "Monaco" "Courier New" ];
      buffer_font_size = 15;
      ui_font_size = 16;
      base_keymap = "VSCode";
      theme = {
        mode = "system";
        light = "One Light";
        dark = "Catppuccin Mocha";
      };

      # Language-specific
      languages = {
        Ruby.language_servers = [ "ruby-lsp" "sorbet" "!solargraph" "!rubocop" ];
        Markdown = {
          soft_wrap = "editor_width";
          format_on_save = "off";
        };
        JSON.tab_size = 2;
        YAML.tab_size = 2;
      };
    };
  };
}
