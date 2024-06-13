# .dotfiles

[GNU Stow](https://www.gnu.org/software/stow/) based dotfiles management.

# Prerequisite

Homebrew

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Git and Stow
```sh
brew install git
brew install stow
```

# Install

Clone the repo(s)

```sh
cd ~
git git@github.com:hamishmorgan/.dotfiles.git
cd ~/.dotfiles
git submodule update --init --recursive
```

Setup links

```sh
cd ~/.dotfiles
stow -v .
```


# Update

### `.gitignore-globals`

```sh
curl -sLw "\n" https://www.toptal.com/developers/gitignore/api/linux,osx,vscode,vim,jetbrains > ~/.gitignore-globals
```

or if you have the `gi` alias in your `.zshrc`

```sh
gi linux,osx,vscode,vim,jetbrains > ~/.gitignore-globals
```
