_:

{
  programs.cargo = {
    enable = true;
    package = null; # Rust toolchain managed separately (rustup)

    settings = {
      build = {
        incremental = true;
        pipelining = true;
      };

      term = {
        color = "auto";
        progress = {
          when = "auto";
          width = 80;
        };
      };

      net = {
        git-fetch-with-cli = true;
        retry = 3;
      };

      alias = {
        b = "build";
        br = "build --release";
        c = "check";
        cr = "check --release";
        r = "run";
        rr = "run --release";
        t = "test";
        tr = "test --release";
        cc = "check --all-targets --all-features";
        bb = "build --all-targets --all-features";
        tt = "test --all-targets --all-features";
        fmt-check = "fmt -- --check";
        lint = "clippy --all-targets --all-features -- -D warnings";
        tree = "tree --depth 3";
      };

      cargo-new = {
        vcs = "git";
        name = "Hamish Morgan";
        email = "hamish.morgan@gmail.com";
      };

      registries.shopify-rust = {
        index = "sparse+https://cargo.cloudsmith.io/shopify/rust/";
        credential-provider = "cargo:token";
      };
    };
  };

  home.file.".rustfmt.toml".text = ''
    edition = "2021"
  '';
}
