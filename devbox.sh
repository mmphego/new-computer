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
    FILES=(.dircolors .bashrc .bash_functions .bash_aliases .gitconfig .bash .profile)
    for file in "${FILES[@]}"; do
        wget --quiet -O "${file}" "https://raw.githubusercontent.com/mmphego/dot-files/master/.dotfiles/${file}" &
    done
}

function install_gpg_stuffs {
    read -r -p 'Enter your FULL name: ' FULLNAME
    git config --global --add user.name FULLNAME
    read -r -p 'Enter your GitHub username: ' GHUSERNAME
    read -r -p 'Enter your GitHub email: ' GHUSEREMAIL
    git config --global --add user.email GHUSEREMAIL
    read -r -s -p 'Enter your GitHub password: ' GHPASSWORD

    echo "Generating GPG keys, please follow the prompts."
    if [ ! -f "github_gpg.py" ]; then
        wget https://raw.githubusercontent.com/mmphego/new-computer/master/github_gpg.py
    fi

    if gpg2 --full-generate-key; then
        MY_GPG_KEY=$(gpg2 --list-secret-keys --keyid-format LONG | grep ^sec | tail -1 | cut -f 2 -d "/" | cut -f 1 -d " ")
        gpg2 --armor --export "${MY_GPG_KEY}" > gpg_keys.txt
        echo "Successfully generated GPG keys!"
        if python github_gpg.py -u "${GHUSERNAME}" -p "${GHPASSWORD}" -f ./gpg_keys.txt; then
            echo
            git config --global commit.gpgsign true
            git config --global user.signingkey "${MY_GPG_KEY}"
            echo "export GPG_TTY=$(tty)" >> ~/.bashrc
            echo
            echo "####################################################"
            echo "GitHub PGP-Keys added successfully!"
            echo "####################################################"
        else
            echo "Something went wrong."
            echo "You will need to do it manually."
            echo "Open: https://github.com/settings/keys"
            echo
        fi
    else
        echo "gpg2 is not installed"
    fi
    rm -rf gpg_keys.txt github_gpg.py || true;
}

function update_packages {
    sudo add-apt-repository -y ppa:git-core/ppa
    sudo apt-get update
    sudo apt-get --purge autoremove -y git
    sudo apt-get install -y build-essential \
                            colordiff \
                            curl \
                            git \
                            gnupg2 \
                            htop \
                            nano \
                            python3.6 \
                            python3.6-dev \
                            vim
    URL=$(curl -s "https://api.github.com/repos/github/hub/releases/latest" | $(command -v grep) "browser_" | cut -d\" -f4 | $(command -v grep) "linux-amd64") || true
    wget "${URL}" -O - | tar -zxf - || true
    echo "Installing Hub"
    find . -name "hub*" -type d | while read -r DIR;do
        sudo prefix=/usr/local "${DIR}"/install
        rm -rf -- hub-linux* || true
    done
}

update_packages
install_dot_files
install_git_hooks
install_gpg_stuffs