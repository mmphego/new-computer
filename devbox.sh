#!/usr/bin/env bash

DIR="${HOME}/.devtools"

function clone_this {
    git clone --depth 1 --progress "https://github.com/mmphego/${1}.git" "${DIR}/$1"
}

function install_git_hooks {
    clone_this git-hooks
    sudo "${DIR}/git-hooks/setup_hooks.sh" install_hooks
}

function install_dot_files {
    cd ~/ || exit 1
    wget -O .dircolors https://raw.githubusercontent.com/mmphego/dot-files/master/.dotfiles/.dircolors
    wget -O .bashrchttps://raw.githubusercontent.com/mmphego/dot-files/master/.dotfiles/.bashrc
    wget -O .bash_functionshttps://raw.githubusercontent.com/mmphego/dot-files/master/.dotfiles/.bash_functions
    wget -O .bash_aliaseshttps://raw.githubusercontent.com/mmphego/dot-files/master/.dotfiles/.bash_aliases
    wget -O .gitconfighttps://raw.githubusercontent.com/mmphego/dot-files/master/.dotfiles/.gitconfig
    wget -O .bashhttps://raw.githubusercontent.com/mmphego/dot-files/master/.dotfiles/.git-completion.bash
    wget -O .nanorchttps://raw.githubusercontent.com/mmphego/dot-files/master/.dotfiles/.nanorc
    wget -O .profilehttps://raw.githubusercontent.com/mmphego/dot-files/master/.dotfiles/.profile
}


install_dot_files
install_git_hooks