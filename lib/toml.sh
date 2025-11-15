#!/usr/bin/env bash
# TOML parsing functions for manifest handling
# Requires: lib/common.sh, lib/output.sh

# Helper function to remove quotes and whitespace from strings
# Used for cleaning file paths extracted from TOML arrays
# Note: This removes ALL quotes, including quotes that might be part of the value
# For TOML values, use get_toml_value() which handles quotes correctly
trim_quotes_and_whitespace() {
    local input="$1"
    # Remove leading/trailing whitespace, single quotes, and double quotes
    echo "$input" | sed 's/^["'\''[:space:]]*//; s/["'\''[:space:]]*$//'
}

# Helper function to escape regex special characters in section names
escape_regex_special_chars() {
    local input="$1"
    echo "$input" | sed 's/\[/\\[/g; s/\]/\\]/g; s/\./\\./g; s/\*/\\*/g; s/\+/\\+/g; s/\?/\\?/g; s/\^/\\^/g; s/\$/\\$/g'
}

# Get TOML value from section (empty string for top-level)
# Checks for key existence to distinguish missing vs empty
get_toml_value() {
    local file="$1"
    local section="$2"  # Empty string for top-level
    local key="$3"

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    # Handle top-level vs section
    if [[ -z "$section" ]]; then
        # Top-level key - search before first [ section
        local section_content
        section_content=$(sed '/^\[/,$d' "$file")
    else
        # Escape regex special characters in section name for safe matching
        local escaped_section
        escaped_section=$(escape_regex_special_chars "$section")

        # Extract section content
        # Only remove last line if it starts with [ (next section), not if it's content
        section_content=$(sed -n "/\[$escaped_section\]/,/^\[/p" "$file" | sed -e '1d' -e '/^\[/,$d')
    fi

    # Check if key exists at all (even if empty)
    # Escape regex special characters in key for safe matching
    local escaped_key
    escaped_key=$(escape_regex_special_chars "$key")
    local key_exists
    key_exists=$(echo "$section_content" | grep -c "^$escaped_key\s*=" 2>/dev/null || echo "0")
    # Remove any whitespace/newlines from grep output
    key_exists="${key_exists//[[:space:]]/}"

    if [[ "$key_exists" -eq 0 ]]; then
        return 1  # Key doesn't exist - use default
    fi

    # Extract key value, strip comments and trim whitespace
    # Use escaped key for safe pattern matching (already computed above)
    local value_line
    value_line=$(echo "$section_content" | \
        grep "^$escaped_key\s*=" | \
        sed 's/#.*$//; s/^\s*//; s/\s*$//' | \
        head -1)

    if [[ -z "$value_line" ]]; then
        return 1
    fi

    # Extract value (handle quoted and unquoted)
    local value
    # Extract everything after first = sign, then trim leading whitespace
    value="${value_line#*=}"
    # Trim leading whitespace (handles spaces, tabs, etc.)
    value="${value#"${value%%[![:space:]]*}"}"

    # Remove quotes if present (handles both single and double quotes)
    # Note: This does not handle escaped quotes within values - document limitation if needed
    # Use parameter expansion for compatibility (macOS bash 3.2 has regex differences)
    if [[ "${value:0:1}" == '"' && "${value: -1}" == '"' ]]; then
        # Double quotes
        value="${value#\"}"
        value="${value%\"}"
    elif [[ "${value:0:1}" == "'" && "${value: -1}" == "'" ]]; then
        # Single quotes
        value="${value#\'}"
        value="${value%\'}"
    fi

    # Return empty string if key exists but value is empty (explicit empty)
    # Caller checks return code: 0 = key exists (even if empty), 1 = key missing
    echo "$value"
    return 0
}

# Get TOML array (supports single-line and multi-line arrays)
# Uses balanced bracket matching to handle nested brackets correctly
# Supports top-level keys (empty section string)
get_toml_array() {
    local file="$1"
    local section="$2"  # Empty string for top-level
    local key="$3"

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    # Handle top-level vs section
    if [[ -z "$section" ]]; then
        # Top-level key - search before first [ section
        local section_content
        section_content=$(sed '/^\[/,$d' "$file")
    else
        # Extract section content
        local escaped_section
        escaped_section=$(escape_regex_special_chars "$section")
        # Get content from section header to next section or end of file
        # Remove section header line itself, keep content lines
        section_content=$(sed -n "/\[$escaped_section\]/,/^\[/p" "$file" | sed -e '1d' -e '/^\[/,$d')
    fi

    # Find array declaration (key = [...] or key = [ ... ])
    # Escape key for safe regex matching
    local escaped_key
    escaped_key=$(escape_regex_special_chars "$key")
    local array_start_line
    array_start_line=$(echo "$section_content" | grep -n "^$escaped_key\s*=" | cut -d: -f1 | head -1)

    if [[ -z "$array_start_line" ]]; then
        return 1
    fi

    # Extract lines starting from array declaration
    # Stop at closing bracket to avoid processing subsequent lines
    local array_lines
    array_lines=$(echo "$section_content" | sed -n "${array_start_line},\$p" | sed "/\]/q")

    # Parse array using balanced bracket matching
    local result_value=""
    local in_quotes=false
    local quote_char=""
    local bracket_depth=0
    local array_started=false
    local current_element=""
    local line_num=0

    # Process character by character (bash 3.2 compatible)
    while IFS= read -r line; do
        ((line_num++))

        # Skip comment lines
        if [[ "$line" =~ ^[[:space:]]*# ]]; then
            continue
        fi

        # Process each character (inline comments handled within loop to respect quotes)
        for ((i=0; i<${#line}; i++)); do
            local char="${line:$i:1}"

            # If we see a '#' outside of quotes, treat as comment and break
            if [[ "$char" == "#" && "$in_quotes" == false ]]; then
                break
            fi

            case "$char" in
                '[')
                    if [[ "$in_quotes" == false ]]; then
                        if [[ "$array_started" == false ]]; then
                            array_started=true
                        fi
                        ((bracket_depth++))
                    else
                        current_element="$current_element$char"
                    fi
                    ;;
                ']')
                    if [[ "$in_quotes" == false ]]; then
                        ((bracket_depth--))
                        if [[ $bracket_depth -eq 0 && "$array_started" == true ]]; then
                            # End of array
                            if [[ -n "$current_element" ]]; then
                                current_element=$(echo "$current_element" | sed 's/^\s*//; s/\s*$//')
                                if [[ -n "$current_element" ]]; then
                                    if [[ -n "$result_value" ]]; then
                                        result_value="$result_value,$current_element"
                                    else
                                        result_value="$current_element"
                                    fi
                                fi
                            fi
                            # Remove quotes and return
                            # Use parameter expansion to avoid sed character class issues
                            result_value="${result_value//\"/}"
                            result_value="${result_value//\'/}"
                            # Remove spaces around commas using parameter expansion (bash 3.2 compatible)
                            local previous_value
                            while true; do
                                previous_value="$result_value"
                                result_value="${result_value// ,/,}"
                                result_value="${result_value//, /,}"
                                # Stop if no changes were made
                                [[ "$result_value" == "$previous_value" ]] && break
                            done
                            echo "$result_value"
                            return 0
                        fi
                    else
                        current_element="$current_element$char"
                    fi
                    ;;
                '"'|"'")
                    if [[ "$in_quotes" == false ]]; then
                        in_quotes=true
                        quote_char="$char"
                        current_element="$current_element$char"
                    elif [[ "$char" == "$quote_char" ]]; then
                        # Closing quote - add to current_element BEFORE toggling in_quotes
                        current_element="$current_element$char"
                        in_quotes=false
                        quote_char=""
                    else
                        # Different quote type (single vs double) - treat as regular character
                        current_element="$current_element$char"
                    fi
                    ;;
                ',')
                    if [[ "$in_quotes" == false && "$array_started" == true && $bracket_depth -eq 1 ]]; then
                        # Comma separator at array level
                        current_element=$(echo "$current_element" | sed 's/^\s*//; s/\s*$//')
                        if [[ -n "$current_element" ]]; then
                            if [[ -n "$result_value" ]]; then
                                result_value="$result_value,$current_element"
                            else
                                result_value="$current_element"
                            fi
                        fi
                        current_element=""
                    else
                        current_element="$current_element$char"
                    fi
                    ;;
                *)
                    # Add character if we're inside the array (started) OR if we're inside quotes
                    # This ensures characters inside quoted strings are captured even before array_started is set
                    if [[ "$array_started" == true || "$in_quotes" == true ]]; then
                        current_element="$current_element$char"
                    fi
                    ;;
            esac
        done

        # Add newline if in quotes (for multi-line strings)
        if [[ "$in_quotes" == true ]]; then
            current_element="$current_element "
        fi
    done <<< "$array_lines"

    # Array not closed properly
    if [[ $bracket_depth -ne 0 ]]; then
        log_error "Unbalanced brackets in array (manifest: $file, section: $section, key: $key)"
        return 1
    fi

    # Handle final element if array was properly closed
    # (in case array ends without trailing comma: [ "a", "b" ])
    if [[ -n "$current_element" ]]; then
        current_element=$(echo "$current_element" | sed 's/^\s*//; s/\s*$//')
        if [[ -n "$current_element" ]]; then
            if [[ -n "$result_value" ]]; then
                result_value="$result_value,$current_element"
            else
                result_value="$current_element"
            fi
        fi
    fi

    # Output result (even if empty array [])
    if [[ -n "$result_value" ]]; then
        # Use parameter expansion to avoid sed character class issues
        result_value="${result_value//\"/}"
        result_value="${result_value//\'/}"
        # Remove spaces around commas using parameter expansion (bash 3.2 compatible)
        local previous_value
        while true; do
            previous_value="$result_value"
            result_value="${result_value// ,/,}"
            result_value="${result_value//, /,}"
            # Stop if no changes were made
            [[ "$result_value" == "$previous_value" ]] && break
        done
        echo "$result_value"
    else
        echo ""  # Empty array
    fi
    return 0
}

# Apply platform-specific target override from manifest
# Bash 3.2 compatible
apply_platform_target_override() {
    local manifest="$1"
    local platform="$2"

    if [[ "$platform" == "linux" ]]; then
        local linux_target
        linux_target=$(get_toml_value "$manifest" "linux" "target")
        if [[ -n "$linux_target" ]]; then
            # Expand ~ to $HOME if present
            if [[ "$linux_target" == ~* ]]; then
                linux_target="${linux_target/#\~/$HOME}"
            fi
            PACKAGE_TARGET="$linux_target"
        fi
    elif [[ "$platform" == "macos" ]]; then
        local macos_target
        macos_target=$(get_toml_value "$manifest" "macos" "target")
        if [[ -n "$macos_target" ]]; then
            # Expand ~ to $HOME if present
            if [[ "$macos_target" == ~* ]]; then
                macos_target="${macos_target/#\~/$HOME}"
            fi
            PACKAGE_TARGET="$macos_target"
        fi
    fi
}

# Get TOML inline table (parses { command = "...", args = [...] })
# Returns: "command|arg1,arg2,arg3" format (pipe-separated, args comma-separated)
# Bash 3.2 compatible character-by-character parsing
get_toml_inline_table() {
    local file="$1"
    local section="$2"  # Empty string for top-level
    local key="$3"

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    # Extract section content
    local section_content
    if [[ -z "$section" ]]; then
        section_content=$(sed '/^\[/,$d' "$file")
    else
        local escaped_section
        escaped_section=$(escape_regex_special_chars "$section")
        # Extract from [section] to next [ or end of file
        section_content=$(sed -n "/\[$escaped_section\]/,/^\[/p" "$file")
        # Remove first line ([section]) and last line if it starts with [ (next section)
        section_content=$(echo "$section_content" | sed '1d')
        if echo "$section_content" | grep -q '^\['; then
            section_content=$(echo "$section_content" | sed '$d')
        fi
    fi

    # Find inline table declaration (key = { ... })
    # Handle quoted keys like ".gitconfig" - match with quotes in the file
    local table_start_line
    # The key comes in as ".gitconfig" (without quotes from get_validation_patterns)
    # Match it with quotes in the file: "key" = { ... }
    # Escape special regex chars in the key for grep, then wrap in quotes
    local escaped_key
    escaped_key=$(escape_regex_special_chars "$key")
    # Try with quotes first (most common case)
    table_start_line=$(echo "$section_content" | grep -n "^\"$escaped_key\"\s*=" | cut -d: -f1 | head -1)
    # If not found, try without quotes (for unquoted keys)
    if [[ -z "$table_start_line" ]]; then
        table_start_line=$(echo "$section_content" | grep -n "^$escaped_key\s*=" | cut -d: -f1 | head -1)
    fi

    if [[ -z "$table_start_line" ]]; then
        return 1
    fi

    # Extract line with inline table
    local table_line
    table_line=$(echo "$section_content" | sed -n "${table_start_line}p" | sed 's/#.*$//')
    # Extract everything after the first = sign (key = { ... })
    # Use awk to split on first = and get everything after it
    table_line=$(echo "$table_line" | awk -F'=' '{if (NF>1) {s=""; for(i=2;i<=NF;i++) {if(i>2) s=s"="; s=s$i}; print s}}')
    # Trim leading/trailing whitespace (handle any whitespace characters)
    table_line=$(echo "$table_line" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')

    # Handle multi-line inline tables (they shouldn't exist in our simplified TOML, but handle just in case)
    # Check if table closes on same line
    local open_braces
    open_braces=$(echo "$table_line" | grep -o '{' | wc -l | tr -d ' ')
    local close_braces
    close_braces=$(echo "$table_line" | grep -o '}' | wc -l | tr -d ' ')

    if [[ -z "$open_braces" ]]; then
        open_braces=0
    fi
    if [[ -z "$close_braces" ]]; then
        close_braces=0
    fi

    # If braces don't match, read more lines (shouldn't happen in our simplified TOML)
    if [[ $open_braces -gt $close_braces ]]; then
        local line_count=$((table_start_line + 1))
        while IFS= read -r next_line; do
            table_line="$table_line$next_line"
            open_braces=$(echo "$table_line" | grep -o '{' | wc -l | tr -d ' ')
            close_braces=$(echo "$table_line" | grep -o '}' | wc -l | tr -d ' ')
            if [[ -z "$open_braces" ]]; then
                open_braces=0
            fi
            if [[ -z "$close_braces" ]]; then
                close_braces=0
            fi
            if [[ $open_braces -eq $close_braces ]]; then
                break
            fi
            ((line_count++))
        done < <(echo "$section_content" | sed -n "$((table_start_line + 1)),\$p")
    fi

    # Parse inline table: { command = "value", args = [...] }
    local in_quotes=false
    local quote_char=""
    local bracket_depth=0
    local in_table=false
    local current_field=""
    local field_name=""
    local command_value=""
    local args_array=""
    local in_array=false
    local array_bracket_depth=0

    # Process character by character
    for ((i=0; i<${#table_line}; i++)); do
        local char="${table_line:$i:1}"

        case "$char" in
            '{')
                if [[ "$in_quotes" == false ]]; then
                    in_table=true
                    ((bracket_depth++))
                    # Don't add { to current_field - it's not part of field name/value
                else
                    current_field="$current_field$char"
                fi
                ;;
            '}')
                if [[ "$in_quotes" == false ]]; then
                    ((bracket_depth--))
                    if [[ $bracket_depth -eq 0 ]]; then
                        # End of table - process last field (if any)
                        # Don't add } to current_field - it's not part of field value
                        if [[ -n "$field_name" && -n "$current_field" ]]; then
                            local trimmed_field_name
                            trimmed_field_name=$(echo "$field_name" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
                            if [[ "$trimmed_field_name" == "command" ]]; then
                                command_value=$(echo "$current_field" | sed 's/^\s*//; s/\s*$//' | sed 's/^["'\'']//; s/["'\'']$//')
                            elif [[ "$trimmed_field_name" == "args" ]]; then
                                args_array=$(echo "$current_field" | sed 's/^\s*//; s/\s*$//')
                            fi
                        elif [[ -z "$field_name" && -n "$current_field" ]]; then
                            # Handle case where last field wasn't processed yet (no trailing comma)
                            # Try to determine field type from context - if current_field looks like an array, it's args
                            if echo "$current_field" | grep -q '^\['; then
                                args_array=$(echo "$current_field" | sed 's/^\s*//; s/\s*$//')
                            fi
                        fi
                        break
                    else
                        current_field="$current_field$char"
                    fi
                else
                    current_field="$current_field$char"
                fi
                ;;
            '[')
                if [[ "$in_quotes" == false && "$in_table" == true ]]; then
                    in_array=true
                    ((array_bracket_depth++))
                fi
                current_field="$current_field$char"
                ;;
            ']')
                if [[ "$in_quotes" == false && "$in_array" == true ]]; then
                    ((array_bracket_depth--))
                    if [[ $array_bracket_depth -eq 0 ]]; then
                        in_array=false
                    fi
                fi
                current_field="$current_field$char"
                ;;
            '=')
                if [[ "$in_quotes" == false && "$in_table" == true && "$in_array" == false ]]; then
                    # Field name before '=' (only if not inside array)
                    field_name=$(echo "$current_field" | sed 's/^\s*//; s/\s*$//')
                    current_field=""
                else
                    current_field="$current_field$char"
                fi
                ;;
            ',')
                if [[ "$in_quotes" == false && "$in_table" == true && "$in_array" == false ]]; then
                    # Field separator (only if not inside array)
                            local trimmed_field_name
                            trimmed_field_name=$(echo "$field_name" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
                            if [[ "$trimmed_field_name" == "command" ]]; then
                                command_value=$(echo "$current_field" | sed 's/^\s*//; s/\s*$//' | sed 's/^["'\'']//; s/["'\'']$//')
                            elif [[ "$trimmed_field_name" == "args" ]]; then
                                args_array=$(echo "$current_field" | sed 's/^\s*//; s/\s*$//')
                            fi
                            field_name=""
                            current_field=""
                else
                    current_field="$current_field$char"
                fi
                ;;
            '"'|"'")
                if [[ "$in_quotes" == false ]]; then
                    in_quotes=true
                    quote_char="$char"
                elif [[ "$char" == "$quote_char" ]]; then
                    in_quotes=false
                    quote_char=""
                fi
                current_field="$current_field$char"
                ;;
            *)
                current_field="$current_field$char"
                ;;
        esac
    done

    # Parse args array if present
    if [[ -n "$args_array" ]]; then
        # Extract array content (remove brackets)
        local args_content
        args_content=$(echo "$args_array" | sed 's/^\[//; s/\]$//')

        # Parse array elements (handle quoted strings)
        local args_list=""
        local in_quotes=false
        local quote_char=""
        local current_arg=""

        for ((i=0; i<${#args_content}; i++)); do
            local char="${args_content:$i:1}"

            case "$char" in
                ',')
                    if [[ "$in_quotes" == false ]]; then
                        # Arg separator
                        current_arg=$(echo "$current_arg" | sed 's/^\s*//; s/\s*$//' | sed 's/^["'\'']//; s/["'\'']$//')
                        if [[ -n "$args_list" ]]; then
                            args_list="$args_list,$current_arg"
                        else
                            args_list="$current_arg"
                        fi
                        current_arg=""
                    else
                        current_arg="$current_arg$char"
                    fi
                    ;;
                '"'|"'")
                    if [[ "$in_quotes" == false ]]; then
                        in_quotes=true
                        quote_char="$char"
                    elif [[ "$char" == "$quote_char" ]]; then
                        in_quotes=false
                        quote_char=""
                    fi
                    current_arg="$current_arg$char"
                    ;;
                *)
                    current_arg="$current_arg$char"
                    ;;
            esac
        done

        # Add last arg
        if [[ -n "$current_arg" ]]; then
            current_arg=$(echo "$current_arg" | sed 's/^\s*//; s/\s*$//' | sed 's/^["'\'']//; s/["'\'']$//')
            if [[ -n "$args_list" ]]; then
                args_list="$args_list,$current_arg"
            else
                args_list="$current_arg"
            fi
        fi

        args_array="$args_list"
    fi

    if [[ -z "$command_value" ]]; then
        return 1
    fi

    # Return format: "command|arg1,arg2,arg3"
    if [[ -n "$args_array" ]]; then
        echo "$command_value|$args_array"
    else
        echo "$command_value|"
    fi
    return 0
}

