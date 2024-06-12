# .dotfiles

[GNU Stow](https://www.gnu.org/software/stow/) based dotfiles management.

# Prerequisite

```sh
brew install git
brew install stow
```

# Install

```sh
cd ~
git git@github.com:hamishmorgan/.dotfiles.git
cd ~/.dotfiles
git submodule update --init --recursive
```

```sh
cd ~/.dotfiles
stow -v .
```


