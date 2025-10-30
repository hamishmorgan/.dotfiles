# Rust Package

Global Rust development configuration including cargo settings, code formatting preferences, and setup documentation.

## What's Included

- **`~/.cargo/config.toml`**: Global cargo configuration
  - Build performance optimizations (incremental builds, pipelining)
  - Convenient cargo command aliases
  - Network and git settings
- **`~/.rustfmt.toml`**: Code formatting preferences
  - Consistent code style across projects
  - Edition 2021 defaults
- **`~/.cargo/config.local.toml.example`**: Template for machine-specific settings

## Installation

### Prerequisites

Rustup must be installed before installing this package. See [Rustup Setup](#rustup-setup) below.

### Install Package

```bash
# From dotfiles repository root
./dot enable rust

# Or manually with stow
stow --verbose --restow --dir=packages --target=$HOME rust
```

### Machine-Specific Configuration

Copy the example file and customize for this machine:

```bash
cp ~/.cargo/config.local.toml.example ~/.cargo/config.local.toml
```

Edit `~/.cargo/config.local.toml` to add:

- Private registry credentials
- Employer-specific configurations
- Machine-specific build optimizations

## Rustup Setup

### First-Time Installation

**macOS (via Homebrew):**

```bash
# Install rustup
brew install rustup

# Initialize rustup (creates ~/.cargo/bin and proxy executables)
rustup-init

# When prompted:
# - Proceed with standard installation (option 1)
# - Allows modification of PATH in shell configs
```

**Linux / Direct Install:**

```bash
# Official installation script
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# When prompted, choose option 1 (proceed with standard installation)
```

### Post-Installation

After running `rustup-init`:

1. **Verify installation:**

   ```bash
   rustup --version
   cargo --version
   rustc --version
   ```

2. **Install useful components:**

   ```bash
   # Rust source code (for rust-analyzer and IDE support)
   rustup component add rust-src

   # Code formatter
   rustup component add rustfmt

   # Linter
   rustup component add clippy

   # Rust analyzer (LSP for IDEs)
   rustup component add rust-analyzer
   ```

3. **Shell integration is automatic:**

   - `rustup-init` creates `~/.cargo/env` (bash/zsh) and `~/.cargo/env.fish` (fish)
   - Dotfiles already source these files (as of PR #120)
   - Completions are configured in shell configs

### Managing Rust Versions

**Install specific versions:**

```bash
# Install specific toolchain
rustup toolchain install 1.85.0

# Install nightly
rustup toolchain install nightly
```

**Per-project overrides:**

```bash
# In project directory
cd ~/my-rust-project

# Use specific version for this project
rustup override set 1.85.0

# Or create rust-toolchain.toml in project root:
cat > rust-toolchain.toml << 'EOF'
[toolchain]
channel = "1.85.0"
components = ["rustfmt", "clippy", "rust-src"]
EOF
```

**Global default:**

```bash
# Set default toolchain
rustup default stable

# Update default toolchain
rustup update stable
rustup default stable
```

### Updating Rust

```bash
# Update all installed toolchains
rustup update

# Update rustup itself
# If installed via Homebrew:
brew upgrade rustup

# If installed via rustup.rs:
rustup self update
```

## Cargo Configuration

### Global Config (`~/.cargo/config.toml`)

Managed by dotfiles. Includes:

- **Build optimizations**: Incremental builds, pipelining
- **Cargo aliases**: Shortcuts like `cargo br` (build --release)
- **Network settings**: Git CLI integration, retries

### Local Config (`~/.cargo/config.local.toml`)

Machine-specific settings **not** managed by dotfiles:

- Private registry credentials
- Employer-specific registries (e.g., Shopify)
- Target-specific compiler flags
- Machine-specific build settings

### Merging Existing Configs

If you already have a `~/.cargo/config.toml`:

1. **Back up existing config:**

   ```bash
   cp ~/.cargo/config.toml ~/.cargo/config.toml.backup
   ```

2. **Extract machine-specific settings:**

   - Move private registries to `~/.cargo/config.local.toml`
   - Move credentials to `~/.cargo/config.local.toml`
   - Keep generic settings in dotfiles version

3. **Install package:**

   ```bash
   ./dot enable rust
   ```

4. **Verify merged config:**

   ```bash
   # View effective configuration (requires nightly)
   cargo +nightly config get
   ```

## Rustfmt Configuration

Global formatting preferences in `~/.rustfmt.toml`:

- Edition 2021 (minimal safe default)

The global config is intentionally minimal to avoid interfering with project-specific
formatting preferences. Projects can define their own `rustfmt.toml` in the project root
for detailed formatting control.

### Using Rustfmt

```bash
# Format current project
cargo fmt

# Check formatting without changing files
cargo fmt -- --check

# Format specific file
rustfmt src/main.rs
```

## Useful Cargo Extensions

These are **not** installed by dotfiles (install per-machine as needed):

```bash
# Automatic recompilation on file changes
cargo install cargo-watch

# Enhanced dependency management
cargo install cargo-edit

# Check for outdated dependencies
cargo install cargo-outdated

# Security audit for dependencies
cargo install cargo-audit

# Generate documentation with examples
cargo install cargo-examples

# Faster incremental builds
cargo install sccache

# Binary size optimization analysis
cargo install cargo-bloat
```

### Using Cargo Aliases

The dotfiles provide useful cargo aliases (from `~/.cargo/config.toml`):

```bash
# Development workflows
cargo c      # check
cargo b      # build
cargo r      # run
cargo t      # test

# Release builds
cargo br     # build --release
cargo cr     # check --release
cargo rr     # run --release
cargo tr     # test --release

# All targets and features
cargo cc     # check --all-targets --all-features
cargo bb     # build --all-targets --all-features
cargo tt     # test --all-targets --all-features

# Code quality
cargo lint        # clippy with warnings as errors
cargo fmt-check   # verify formatting without changing

# Information
cargo outdated    # check for outdated deps (requires cargo-outdated)
cargo tree        # show dependency tree

# Development workflows (commented out by default)
# cargo dev       # watch -x check (requires cargo-watch)
```

## Troubleshooting

### Cargo/Rustc Not Found

If `cargo` or `rustc` are not available globally:

1. **Verify rustup is installed:**

   ```bash
   rustup --version
   ```

2. **Check ~/.cargo/bin exists:**

   ```bash
   ls -la ~/.cargo/bin/
   ```

3. **Verify PATH includes ~/.cargo/bin:**

   ```bash
   echo $PATH | tr ':' '\n' | grep cargo
   ```

4. **Re-run rustup-init if needed:**

   ```bash
   rustup-init
   ```

### Homebrew Rustup Issues

The Homebrew `rustup` package is "keg-only" and doesn't automatically create `~/.cargo/bin`.
You must run `rustup-init` after `brew install rustup`:

```bash
brew install rustup
rustup-init  # Required - creates ~/.cargo/bin and proxy executables
```

### Cargo Config Not Applied

Cargo merges configurations from multiple locations in this order (later overrides earlier):

1. `$CARGO_HOME/config.toml` (or `~/.cargo/config.toml`)
2. `$(pwd)/.cargo/config.toml` (project-specific)
3. `$CARGO_HOME/config.local.toml` (via `[include]`)

Verify which config is being used:

```bash
# Requires nightly toolchain
cargo +nightly config get
```

### Private Registry Credentials

**Shopify example** (place in `~/.cargo/config.local.toml`):

```toml
[registries.shopify-rust]
index = "sparse+https://cargo.cloudsmith.io/shopify/rust/"
credential-provider = "cargo:token"
```

Store credentials in `~/.cargo/credentials.toml` (auto-managed by cargo):

```bash
cargo login --registry shopify-rust
```

## Best Practices

### Per-Project Configuration

Use `rust-toolchain.toml` in project root for version pinning:

```toml
[toolchain]
channel = "1.85.0"
components = ["rustfmt", "clippy", "rust-src", "rust-analyzer"]
targets = ["wasm32-unknown-unknown"]
```

### Project-Specific Formatting

Create `rustfmt.toml` in project root for detailed formatting control:

```toml
edition = "2021"
max_width = 120
hard_tabs = false
tab_spaces = 4
```

### CI/CD Considerations

In CI environments, you may want to:

```bash
# Disable incremental builds (saves disk space)
export CARGO_INCREMENTAL=0

# Use all available cores
export CARGO_BUILD_JOBS=$(nproc)
```

## Additional Resources

- [The Cargo Book](https://doc.rust-lang.org/cargo/)
- [Rustup Documentation](https://rust-lang.github.io/rustup/)
- [Rustfmt Configuration](https://rust-lang.github.io/rustfmt/)
- [Clippy Lints](https://rust-lang.github.io/rust-clippy/)
- [Rust Edition Guide](https://doc.rust-lang.org/edition-guide/)

## Notes

- The `~/.cargo/env` and `~/.cargo/env.fish` files are created by `rustup-init` and remain outside version control
- Rust toolchains are managed by rustup in `~/.rustup/` (not in dotfiles)
- Shell completions for rustup and cargo are configured in shell configs (bash, zsh, fish)
- This package complements but does not replace rustup - both work together
