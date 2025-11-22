# Generate uv and uvx completions if uv is installed
if command -q uv
    set -l completions_dir "$__fish_config_dir/completions"
    # Generate uv completions
    if not test -f "$completions_dir/uv.fish"
        mkdir -p "$completions_dir"
        uv generate-shell-completion fish >"$completions_dir/uv.fish"
    end
end
