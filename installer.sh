#!/usr/bin/env bash

# Generally this script will install basic Ubuntu packages and extras,
# latest Python pip and defined dependencies in pip-requirements.
# Docker, Sublime Text and VSCode, Slack, Megasync, Mendeley and Latex support
# Some configs reused from: https://github.com/nnja/new-computer

set -ex

echo "Xubuntu Install Setup Script"
echo "Note: You need to be sudo before you continue"
echo "By Mpho Mphego"

# Set the colours you can use
black=$(tput setaf 0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
# Resets the style
reset=`tput sgr0`

# Color-echo.
# arg $1 = Color
# arg $2 = message
cecho() {
  echo "${1}${2}${reset}"
  return
}

echon() {
  echo -e "\n"
  return
}


echon
cecho $red "###############################################"
cecho $red "#        DO NOT RUN THIS SCRIPT BLINDLY       #"
cecho $red "#         YOU'LL PROBABLY REGRET IT...        #"
cecho $red "#                                             #"
cecho $red "#              READ IT THOROUGHLY             #"
cecho $red "#         AND EDIT TO SUIT YOUR NEEDS         #"
cecho $red "###############################################"
echon

# Set continue to false by default.
CONTINUE=false

cecho $red "Have you read through the script you're about to run and "
cecho $red "understood that it will make changes to your computer? (y/n)"

# read -r response
# if [[ "${response}" =~ ^([yY][eE][sS]|[yY])$ ]]; then
#   CONTINUE=true
# fi
CONTINUE=true

if ! "${CONTINUE}"; then
  # Check if we're continuing and output a message if not
  cecho "${red}" "Please go read the script, it only takes a few minutes"
  exit
fi

if [ "${EUID}" -ne 0 ]
  then cecho $red "Please run script as root!!!"
  exit
fi

############################################
# Prerequisite: Update package source list #
############################################

function InstallThis {
    for pkg in $@; do
        apt-get install -y "${pkg}";
    done
}

echo "Running package updates..."
apt-get update
echo "Installing wget curl and gdebi as requirements!"
InstallThis wget curl gdebi

function ReposInstaller {
    Version=$(lsb_release -cs)
    add-apt-repository -y ppa:git-core/ppa

    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    [ -z "${Version}" ] || add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu ${Version} stable"

    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
    sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

    add-apt-repository -y ppa:maarten-baert/simplescreenrecorder
    add-apt-repository -y ppa:openshot.developers/ppa
    apt-get update
}



#############################################
### Install few global python packages
#############################################
function PythonInstaller {
    cecho "${cyan}" "Installing global Python packages..."
    curl https://bootstrap.pypa.io/get-pip.py | sudo python
    apt-get -y install python-dev python-tk
    pip install --ignore-installed -U -r pip-requirements.txt
}

function DockerSetUp {
    cecho "${cyan}" "Setting up Docker..."
    gpasswd -a  "$(users)" docker
    usermod -a -G docker "$(users)"
}

function SlackInstaller {
    cecho "${cyan}" "Installing Slack..."
    wget -O slack.deb https://downloads.slack-edge.com/linux_releases/slack-desktop-3.3.3-amd64.deb
    gdebi -n slack.deb
}

function MEGAInstaller {
    ID=$(grep ^VERSION_ID /etc/os-release | cut -d "=" -f2 | tr -d '"')
    wget "https://mega.nz/linux/MEGAsync/xUbuntu_${ID}/amd64/megasync-xUbuntu_${ID}_amd64.deb"
    gdebi -n "megasync-xUbuntu_${ID}_amd64.deb"
}

function MendeleyInstaller {
    wget -O mendeley.deb https://www.mendeley.com/repositories/ubuntu/stable/amd64/mendeleydesktop-latest
    gdebi -n mendeley.deb
}

function LatexInstaller {
    InstallThis pandoc texlive-font-utils latexmk texlive-latex-extra gummi \
                   texlive-pictures texlive-pstricks texlive-science texlive-xetex \
                   chktex
}

function GitInstaller {
    wget -O libc.deb http://za.archive.ubuntu.com/ubuntu/pool/main/g/glibc/libc6_2.28-0ubuntu1_amd64.deb
    gdebi -n libc.deb || true
    InstallThis git
    wget https://github.com/github/hub/releases/download/v2.6.0/hub-linux-386-2.6.0.tgz -O - | tar -zxf -
    prefix=/usr/local hub-linux-386-2.6.0/install
    rm -rf hub-linux*
}

function PackagesInstaller {

    ### Productivity tools
    InstallThis terminator \
        htop \
        vim \
        rar \
        chromium-browser \
        gawk \
        sqlite3 \
        axel \
        docker-ce \

    ### Docker Setup
    DockerSetUp

    GitInstaller

    # Python Packages
    PythonInstaller

    ### Library dependencies
    InstallThis libcurl4-gnutls-dev libexpat1-dev libz-dev libssl-dev \
        libreadline-dev libyaml-dev zlib1g-dev libsqlite3-dev libxml2-dev \
        libxslt1-dev libcurl4-openssl-dev libffi-dev libgtk2.0-0

    ### Compilers and GNU dependencies
    InstallThis g++ gettext dh-autoreconf autoconf automake

    ### Network tools
    InstallThis autofs autossh bash-completion openssh-server sshfs evince gparted tree wicd \
        gnome-calculator

    ### Fun tools
    InstallThis cowsay fortune-mod

    ### Dev Editors and tools
    InstallThis code
    InstallThis sublime-text
    InstallThis shellcheck
    MEGAInstaller

    ### Chat / Video Conference
    SlackInstaller

    ### Music, Pictures and Video
    InstallThis vlc youtube-dl simplescreenrecorder openshot-qt pinta

    ### System and Security tools
    InstallThis ca-certificates build-essential software-properties-common apt-transport-https \
        laptop-mode-tools xubuntu-icon-theme xfce4-*

    MendeleyInstaller
    LatexInstaller
}

function Cleanup {
    apt clean && rm -rf -- *.deb* *.gpg* *.py*
}

ReposInstaller
PackagesInstaller
### Minor Clean-up
Cleanup
