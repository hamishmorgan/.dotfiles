# Generate uv and uvx completions if uv is installed
if command -v uv >/dev/null 2>&1
    set -l completions_dir "$__fish_config_dir/completions"
    # Generate uv completions
    if not test -f "$completions_dir/uv.fish"
        mkdir -p "$completions_dir"
        uv generate-shell-completion fish >"$completions_dir/uv.fish"
    end
end
