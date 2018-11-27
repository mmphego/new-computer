#!/usr/bin/env bash

# Generally this script will install basic Ubuntu packages and extras,
# latest Python pip and defined dependencies in pip-requirements.
# Docker, Sublime Text and VSCode, Slack, Megasync, Mendeley and Latex support

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

set -e
set -o xtrace
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y wget curl

function Repositories {
    Version=$(grep ^UBUNTU_CODENAME /etc/os-release | cut -d "=" -f2)
    add-apt-repository -yu ppa:git-core/ppa

    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository -yu "deb [arch=amd64] https://download.docker.com/linux/ubuntu ${Version} stable"

    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
    sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

    add-apt-repository -yu ppa:maarten-baert/simplescreenrecorder
    add-apt-repository -yu ppa:openshot.developers/ppa
    apt-get update
}

function Basics {
    apt-get install -y terminator
    apt-get install -y dh-autoreconf libcurl4-gnutls-dev libexpat1-dev \
                   gettext libz-dev libssl-dev
    apt-get install -y build-essential zlib1g-dev build-essential \
                   libssl-dev libreadline-dev libyaml-dev dselect \
                   libsqlite3-dev sqlite3 libxml2-dev htop \
                   libxslt1-dev libcurl4-openssl-dev libffi-dev vim \
                   software-properties-common apt-transport-https \
                   ca-certificates libgtk2.0-0 laptop-mode-tools \
                   autoconf autofs automake autossh axel bash-completion \
                   openssh-server sshfs evince gparted tree \
                   xubuntu-icon-theme pinta shellcheck wicd gnome-calculator \
		           gawk xfce4-* simplescreenrecorder openshot-qt
}

function Python {
    curl https://bootstrap.pypa.io/get-pip.py | sudo python
    apt -y install python-dev python-tk
    pip install -r pip-requirements.txt
}

function Docker {
    apt -y install docker-ce
    gpasswd -a ${USER} docker
    usermod -a -G docker ${USER}
}

function IDEs {
    apt -y install code sublime-text
}


function Slack {
    wget -O slack.deb https://downloads.slack-edge.com/linux_releases/slack-desktop-3.3.3-amd64.deb
    gdebi -n slack.deb
}

function MEGA {
    ID=$(grep ^VERSION_ID /etc/os-release | cut -d "=" -f2 | tr -d '"')
    wget "https://mega.nz/linux/MEGAsync/xUbuntu_${ID}/amd64/megasync-xUbuntu_${ID}_amd64.deb"
    gdebi -n "megasync-xUbuntu_${ID}_amd64.deb"
}

function Mendeley {
    wget -O mendeley.deb https://www.mendeley.com/repositories/ubuntu/stable/amd64/mendeleydesktop-latest
    gdebi -n mendeley.deb
}

function Latex {
    apt-get install -y pandoc texlive-font-utils latexmk texlive-latex-extra gummi \
                   texlive-pictures texlive-pstricks texlive-science texlive-xetex \
                   chktex
}

function Git {
	wget -O libc.deb http://za.archive.ubuntu.com/ubuntu/pool/main/g/glibc/libc6_2.28-0ubuntu1_amd64.deb
	gdebi -n libc.deb || true
    apt-get ls
    install -y git
}

function Cleanup {
    apt clean && rm -rf *.deb *.gpg *.py*
}


Repositories
Git
Basics
Python
IDEs
MEGA
Mendeley
Latex
Docker
Slack
Cleanup
