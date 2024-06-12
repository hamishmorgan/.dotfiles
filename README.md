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



# Update stuff

### Global gitignores 

```sh
curl -sLw "\n" https://www.toptal.com/developers/gitignore/api/linux,osx,vscode,vim,jetbrains > ~/.gitignore-globals
```
