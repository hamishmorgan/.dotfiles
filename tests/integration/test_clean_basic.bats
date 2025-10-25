#!/usr/bin/env bats
# Basic integration tests for bin/disk-cleanup
# These tests use only core bats functionality (no bats-assert required)

setup() {
  export CLEANUP_LOG_DIR="$BATS_TEST_TMPDIR/logs"
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME"
  mkdir -p "$CLEANUP_LOG_DIR"
  CLEAN_SCRIPT="$BATS_TEST_DIRNAME/../../bin/disk-cleanup"
}

@test "disk-cleanup is executable" {
  [[ -x "$CLEAN_SCRIPT" ]]
}

@test "disk-cleanup has correct shebang" {
  local first_line
  first_line=$(head -1 "$CLEAN_SCRIPT")
  [[ "$first_line" == "#!/usr/bin/env bash" ]]
}

@test "disk-cleanup bash 3.2 compatibility - no associative arrays" {
  ! grep -q "declare -A" "$CLEAN_SCRIPT"
}

@test "disk-cleanup bash 3.2 compatibility - no mapfile" {
  ! grep -q "mapfile" "$CLEAN_SCRIPT"
}

@test "disk-cleanup bash 3.2 compatibility - no &>> redirect" {
  ! grep -q "&>>" "$CLEAN_SCRIPT"
}

@test "disk-cleanup passes shellcheck" {
  if ! command -v shellcheck &> /dev/null; then
    skip "shellcheck not installed"
  fi

  shellcheck "$CLEAN_SCRIPT"
}

@test "disk-cleanup --help shows usage" {
  run "$CLEAN_SCRIPT" --help
  [[ $status -eq 0 ]]
  [[ "$output" =~ "Disk Space Cleanup Utility" ]]
  [[ "$output" =~ "USAGE:" ]]
  [[ "$output" =~ "OPTIONS:" ]]
}

@test "disk-cleanup --version shows version" {
  run "$CLEAN_SCRIPT" --version
  [[ $status -eq 0 ]]
  [[ "$output" =~ "version" ]]
  [[ "$output" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]
}

@test "disk-cleanup --dry-run runs without errors" {
  run "$CLEAN_SCRIPT" --dry-run
  [[ $status -eq 0 ]]
  [[ "$output" =~ "Dry run completed" ]]
}

@test "disk-cleanup --yes runs in non-interactive mode" {
  run "$CLEAN_SCRIPT" --yes --quiet --dry-run
  [[ $status -eq 0 ]]
}

@test "disk-cleanup --only filters categories" {
  run "$CLEAN_SCRIPT" --dry-run --only=languages --quiet
  [[ $status -eq 0 ]]
}

@test "disk-cleanup --exclude skips categories" {
  run "$CLEAN_SCRIPT" --dry-run --exclude=docker,git --quiet
  [[ $status -eq 0 ]]
}

@test "disk-cleanup creates log file" {
  run "$CLEAN_SCRIPT" --dry-run --quiet
  [[ $status -eq 0 ]]
  [[ -d "$CLEANUP_LOG_DIR" ]]

  local log_count
  log_count=$(find "$CLEANUP_LOG_DIR" -name "cleanup-*.log" -type f | wc -l)
  [[ $log_count -gt 0 ]]
}

@test "disk-cleanup log contains START and END" {
  run "$CLEAN_SCRIPT" --dry-run --quiet
  [[ $status -eq 0 ]]

  local log_file
  log_file=$(find "$CLEANUP_LOG_DIR" -name "cleanup-*.log" -type f | head -1)
  [[ -f "$log_file" ]]

  grep -q "START cleanup" "$log_file"
  grep -q "END cleanup" "$log_file"
}

@test "disk-cleanup respects CLEANUP_LOG_DIR env var" {
  local custom_log="$BATS_TEST_TMPDIR/custom_logs"
  export CLEANUP_LOG_DIR="$custom_log"

  run "$CLEAN_SCRIPT" --dry-run --quiet
  [[ $status -eq 0 ]]
  [[ -d "$custom_log" ]]

  local log_count
  log_count=$(find "$custom_log" -name "cleanup-*.log" -type f | wc -l)
  [[ $log_count -gt 0 ]]
}

@test "disk-cleanup handles unknown option" {
  run "$CLEAN_SCRIPT" --unknown-option
  [[ $status -eq 2 ]]
  [[ "$output" =~ "Unknown option" ]]
}

@test "disk-cleanup --aggressive mode" {
  run "$CLEAN_SCRIPT" --dry-run --aggressive --quiet
  [[ $status -eq 0 ]]
}

@test "disk-cleanup --very-aggressive mode" {
  run "$CLEAN_SCRIPT" --dry-run --very-aggressive --quiet
  [[ $status -eq 0 ]]
}

@test "disk-cleanup --verbose shows more output" {
  run "$CLEAN_SCRIPT" --dry-run --verbose
  [[ $status -eq 0 ]]
  # Verbose should have more lines than quiet
  local line_count
  line_count=$(echo "$output" | wc -l)
  [[ $line_count -gt 5 ]]
}

@test "disk-cleanup --quiet shows minimal output" {
  run "$CLEAN_SCRIPT" --dry-run --quiet
  [[ $status -eq 0 ]]
  # Quiet should have minimal lines
  local line_count
  line_count=$(echo "$output" | wc -l)
  [[ $line_count -lt 10 ]]
}

@test "disk-cleanup multiple flags combine correctly" {
  run "$CLEAN_SCRIPT" --dry-run --aggressive --only=languages --quiet
  [[ $status -eq 0 ]]
}

@test "disk-cleanup --prune-git flag accepted" {
  run "$CLEAN_SCRIPT" --dry-run --prune-git --quiet
  [[ $status -eq 0 ]]
}

@test "disk-cleanup --aggressive-git flag accepted" {
  run "$CLEAN_SCRIPT" --dry-run --aggressive-git --quiet
  [[ $status -eq 0 ]]
}

@test "disk-cleanup --system-caches flag accepted" {
  run "$CLEAN_SCRIPT" --dry-run --system-caches --quiet
  [[ $status -eq 0 ]]
}

@test "disk-cleanup --detailed-space flag accepted" {
  run "$CLEAN_SCRIPT" --dry-run --detailed-space --quiet
  [[ $status -eq 0 ]]
}

@test "disk-cleanup shows categories in output" {
  run "$CLEAN_SCRIPT" --dry-run
  [[ $status -eq 0 ]]
  # Should show at least some category headers
  [[ "$output" =~ "Language Tools" ]] || [[ "$output" =~ "Package Managers" ]]
}

