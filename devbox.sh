#!/usr/bin/env bash

DIR="${HOME}/.devtools"

function clone_this {
    git clone --depth 1 --progress "https://github.com/mmphego/${1}.git" "${DIR}/$1"
}

function install_git_hooks {
    clone_this git-hooks
    sudo "${DIR}/.git-hooks/setup_hooks.sh" install_hooks
}

function install_dot_files {
    cd ~/ || exit 1
    wget https://raw.githubusercontent.com/mmphego/dot-files/master/.dotfiles/.dircolors
    wget https://raw.githubusercontent.com/mmphego/dot-files/master/.dotfiles/.bashrc
    wget https://raw.githubusercontent.com/mmphego/dot-files/master/.dotfiles/.bash_functions
    wget https://raw.githubusercontent.com/mmphego/dot-files/master/.dotfiles/.bash_aliases
    wget https://raw.githubusercontent.com/mmphego/dot-files/master/.dotfiles/.gitconfig
    wget https://raw.githubusercontent.com/mmphego/dot-files/master/.dotfiles/.git-completion.bash
    wget https://raw.githubusercontent.com/mmphego/dot-files/master/.dotfiles/.nanorc
    wget https://raw.githubusercontent.com/mmphego/dot-files/master/.dotfiles/.profile
}


install_dot_files
install_git_hooks