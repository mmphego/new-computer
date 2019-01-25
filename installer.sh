#!/usr/bin/env bash

# Generally this script will install basic Ubuntu packages and extras,
# latest Python pip and defined dependencies in pip-requirements.
# Docker, Sublime Text and VSCode, Slack, Megasync, Mendeley, Latex support and etc
# Some configs reused from: https://github.com/nnja/new-computer and,
# https://github.com/JackHack96/dell-xps-9570-ubuntu-respin

set -e pipefail

# Check if the script is running under Ubuntu 16.04 or Ubuntu 18.04
if [ "$(lsb_release -c -s)" != "bionic" -a "$(lsb_release -c -s)" != "xenial" ]; then
    >&2 echo "This script is made for Ubuntu 18.04 or Ubuntu 16.04!"
    exit 1
fi

# Set the colours you can use
# black=$(tput setaf 0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
# magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
# Resets the style
reset=$(tput sgr0)

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

cecho "${blue}" "Xubuntu Install Setup Script"
cecho "${blue}" "Note: You need to be sudo before you continue"
cecho "${blue}" "By Mpho Mphego"

echon
cecho "${red}" "###############################################"
cecho "${red}" "#        DO NOT RUN THIS SCRIPT BLINDLY       #"
cecho "${red}" "#         YOU'LL PROBABLY REGRET IT...        #"
cecho "${red}" "#                                             #"
cecho "${red}" "#              READ IT THOROUGHLY             #"
cecho "${red}" "#         AND EDIT TO SUIT YOUR NEEDS         #"
cecho "${red}" "###############################################"
echon

# Set continue to false by default.
CONTINUE=false

if ! "${TRAVIS}"; then
    cecho "${red}" "Have you read through the script you're about to run and "
    cecho "${red}" "understood that it will make changes to your computer? (y/n)"
    read -t 10 -r response
    if [[ "${response}" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      CONTINUE=true
    fi
else
    cecho "${yellow}" "Running Continuous Integration."
    CONTINUE=true
fi

if ! "${CONTINUE}"; then
  # Check if we're continuing and output a message if not
  cecho "${red}" "Please go read the script, it only takes a few minutes"
  exit 1
fi

# Here we go.. ask for the administrator password upfront and run a
# keep-alive to update existing `sudo` time stamp until script has finished
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

############################################
# Prerequisite: Update package source list #
############################################

function InstallThis {
    for pkg in "$@"; do
        sudo apt-get install -y "${pkg}" || true;
    done
}

cecho "${green}" "Running package updates..."
sudo apt-get update -qq
cecho "${green}" "Installing wget curl and gdebi as requirements!"
InstallThis wget curl gdebi

function ReposInstaller {
    cecho "${green}" "Adding APT Repositories."
    Version=$(lsb_release -cs)

    ## Git
    sudo add-apt-repository -y ppa:git-core/ppa

    ## Sublime Text
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

    ## Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    [ -z "${Version}" ] || sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu ${Version} stable"

    ## VSCode
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

    ## Atom
    sudo add-apt-repository -y ppa:webupd8team/atom

    ## Video tools
    sudo add-apt-repository -y ppa:maarten-baert/simplescreenrecorder
    sudo add-apt-repository -y ppa:openshot.developers/ppa
    sudo apt-get update

    ## Laptop battery management
    sudo add-apt-repository -y ppa:linuxuprising/apps
    sudo add-apt-repository -y ppa:linrunner/tlp
}

## Install few global Python packages
function PythonInstaller {
    cecho "${cyan}" "Installing global Python packages..."
    sudo apt-get -y install python-dev python-tk
    curl https://bootstrap.pypa.io/get-pip.py | sudo python
    pip install --user --ignore-installed -U -r pip-requirements.txt
}

function SlackInstaller {
    cecho "${cyan}" "Installing Slack..."
    wget -O slack.deb https://downloads.slack-edge.com/linux_releases/slack-desktop-3.3.3-amd64.deb
    sudo gdebi -n slack.deb
}

function MEGAInstaller {
    ID=$(grep ^VERSION_ID /etc/os-release | cut -d "=" -f2 | tr -d '"')
    wget "https://mega.nz/linux/MEGAsync/xUbuntu_${ID}/amd64/megasync-xUbuntu_${ID}_amd64.deb"
    sudo gdebi -n "megasync-xUbuntu_${ID}_amd64.deb"
}

function MendeleyInstaller {
    wget -O mendeley.deb https://www.mendeley.com/repositories/ubuntu/stable/amd64/mendeleydesktop-latest
    sudo gdebi -n mendeley.deb
}

function AtomInstaller {
    # Atom text editor
    wget -O atom.deb https://atom.io/download/deb
    sudo gdebi -n atom.deb
}

function xUbuntuPackages {
    InstallThis xubuntu-icon-theme xfce4-*
}

function LatexInstaller {
    InstallThis chktex \
        latexmk \
        pandoc \
        texlive-font-utils \
        texlive-latex-extra \
        gummi \
        texlive-pictures \
        texlive-pstricks \
        texlive-science \
        texlive-xetex
}

function GitInstaller {
    cecho "${cyan}" "Installing Git..."
    # wget -O libc.deb http://za.archive.ubuntu.com/ubuntu/pool/main/g/glibc/libc6_2.28-0ubuntu1_amd64.deb
    # sudo gdebi -n libc.deb || true
    InstallThis git
    wget https://github.com/github/hub/releases/download/v2.6.0/hub-linux-386-2.6.0.tgz -O - | tar -zxf -
    sudo prefix=/usr/local hub-linux-386-2.6.0/install
    rm -rf hub-linux*
}

function TravisClientInstaller {
    cecho "${cyan}" "Installing Travis-CI CLI client."
    sudo gem install -n /usr/local/bin travis --no-rdoc --no-ri
}

function DELL_XPS_TWEAKS {
    echon
    cecho "${red}" "############################################################"
    cecho "${red}" "#                                                          #"
    cecho "${red}" "#   A collection of scripts and tweaks to make             #"
    cecho "${red}" "#   Ubuntu 18.04 run smooth on Dell XPS 15 9570            #"
    cecho "${red}" "#                                                          #"
    cecho "${red}" "#            DO NOT RUN THIS SCRIPT BLINDLY                #"
    cecho "${red}" "#               YOU'LL PROBABLY REGRET IT...               #"
    cecho "${red}" "#                                                          #"
    cecho "${red}" "#               READ IT THOROUGHLY                         #"
    cecho "${red}" "#           AND EDIT TO SUIT YOUR NEEDS                    #"
    cecho "${red}" "#               GO VIEW THE SCRIPT HERE!                   #"
    cecho "${red}" "#                                                          #"
    cecho "${red}" "#   https://github.com/mmphego/dell-xps-9570-ubuntu-respin #"
    cecho "${red}" "#                                                          #"
    cecho "${red}" "############################################################"

    echon
    if ! "${TRAVIS}"; then
        cecho "${red}" "Note that some of these changes require a logout/restart to take effect."
        echo -n "Do you want to proceed with tweaking your Dell XPS? (y/n):-> "
        read -t 10 -r response
        if [ "$response" != "${response#[Yy]}" ] ;then
            bash -c "$(curl -fsSL https://raw.githubusercontent.com/mmphego/dell-xps-9570-ubuntu-respin/master/xps-tweaks.sh)"
        fi
    fi

}

##########################################
############# Package Set Up #############
##########################################
function DockerSetUp {
    cecho "${cyan}" "Setting up Docker..."
    sudo gpasswd -a  "$(users)" docker
    sudo usermod -a -G docker "$(users)"
}

function VSCodeSetUp {
    cecho "${cyan}" "Installing VSCode plugins..."
    while read -r pkg; do
        code --install-extension "${pkg}";
    done < code_plugins.txt
}

function ArduinoUDevFixes {
    cecho "${cyan}" "Setting up UDev rules for platformio"
    cecho "${red}" "See: https://docs.platformio.org/en/latest/faq.html#id15"
    curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/develop/scripts/99-platformio-udev.rules | sudo tee /etc/udev/rules.d/99-platformio-udev.rules
    sudo service udev restart
    sudo usermod -a -G dialout "${USER}"
    sudo usermod -a -G plugdev "${USER}"
}

function GitSetUp {

    if ! "${TRAVIS}"; then
        #############################################
        ### Generate ssh keys & add to ssh-agent
        ### See: https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/
        #############################################

        cecho "${cyan}" "Setting up Git..."
        echo "Generating ssh keys, adding to ssh-agent..."
        read -t 10 -r -p 'Input your full name: ' username
        git config --global user.name "${username}"
        read -t 10 -r -p 'Input email for ssh key: ' useremail
        git config --global user.email "${useremail}"
        git config --global push.default simple

        echo "Use default ssh file location, enter a passphrase: "
        ssh-keygen -t rsa -b 4096 -C "${useremail}"  # will prompt for password
        eval "$(ssh-agent -s)"

        # Now that sshconfig is synced add key to ssh-agent and
        # store passphrase in keychain
        ssh-add -K ~/.ssh/id_rsa

        #############################################
        ### Add ssh-key to GitHub via api
        #############################################

        cecho "${green}" "Adding ssh-key to GitHub (via api)..."
        cecho "${red}" "Important! For this step, use a github personal token with the admin:public_key permission."
        cecho "${red}" "If you don't have one, create it here: https://github.com/settings/tokens/new"
        echon
        cecho "${red}" "Now, have you read through the script you're about to run and "
        cecho "${red}" "understood that it will make changes to your computer?"
        cecho "${red}" "If you would like to continue press: y else n"
        read -t 10 -r response
        if [[ "${response}" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            retries=3
           while read -r key; do SSH_KEY="${key}"; done < ~/.ssh/id_rsa.pub
            for ((i=0; i<retries; i++)); do
                  read -r -p 'GitHub username: ' ghusername
                  read -r -p 'Machine name: ' ghtitle
                  read -r -sp 'GitHub personal token: ' ghtoken

                  gh_status_code=$(curl -o /dev/null -s -w "%{http_code}\n" -u "${ghusername}:${ghtoken}" -d '{"title":"'"${ghtitle}"'","key":"'"${SSH_KEY}"'"}' 'https://api.github.com/user/keys')

                  if (( "${gh_status_code}" == 201)); then
                      cecho "${cyan}" "GitHub ssh key added successfully!"
                      break
                  else
                        echo "Something went wrong. Enter your credentials and try again..."
                        echo -n "Status code returned: ${gh_status_code}"
                  fi
            done
            [[ "${retries}" -eq i ]] && cecho "${red}" "Adding ssh-key to GitHub failed! Try again later."
        fi
    fi
}


function installDotfiles {
    #############################################
    ### Install dotfiles repo
    #############################################
    cecho "${red}" "Do you want to clone and install dotfiles? (y/n)"
    if ! "${TRAVIS}"; then
        read -t 10 -r response
        if [[ "${response}" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            cd ~/
            git init -q
            cecho "${cyan}" "Cloning (Overwriting) dot-files into ~/ "
            git remote add -f -m origin git@github.com:mmphego/dot-files.git
            git pull -f || true
        fi
    fi
}

##########################################
###### Simplified Package Installer ######
##########################################
function PackagesInstaller {

    ### Compilers and GNU dependencies
    InstallThis g++ gettext dh-autoreconf autoconf automake clang ruby-dev ruby

    ### Library dependencies
    InstallThis libcurl4-gnutls-dev libexpat1-dev libz-dev libssl-dev \
        libreadline-dev libyaml-dev zlib1g-dev libsqlite3-dev libxml2-dev \
        libxslt1-dev libcurl4-openssl-dev libffi-dev libgtk2.0-0

    ### System and Security tools
    InstallThis ca-certificates build-essential \
        software-properties-common apt-transport-https \
        tlp tlpui

    ### Network tools
    InstallThis autofs autossh bash-completion openssh-server sshfs evince gparted tree wicd \
        gnome-calculator ethtool

    ### Fun tools
    InstallThis cowsay fortune-mod

    # Packages for xUbuntu
    xUbuntuPackages

    ### Productivity tools
    GitInstaller
    InstallThis terminator \
        htop \
        vim \
        rar \
        chromium-browser \
        gawk \
        sqlite3 \
        axel \
        docker-ce \
        colordiff
    TravisClientInstaller

    # Python Packages
    PythonInstaller

    ### Dev Editors and tools
    InstallThis code
    if [ -f "code_plugins.txt" ]; then
        VSCodeSetUp;
    fi
    InstallThis sublime-text
    AtomInstaller
    if command -v platformio >/dev/null ;then
        ArduinoUDevFixes;
    fi

    ## Linters
    InstallThis shellcheck

    ## Cloud
    MEGAInstaller

    ### Chat / Video Conference
    SlackInstaller

    ### Music, Pictures and Video
    InstallThis vlc youtube-dl simplescreenrecorder openshot-qt pinta

    ### Academic tools
    MendeleyInstaller
    LatexInstaller

    ####################
    ### Setup
    ####################
    DockerSetUp
    GitSetUp
}

function Cleanup {
    cecho "${red}" "Note that some of these changes require a logout/restart to take effect."
    echon
    if ! "${TRAVIS}"; then
        echo -n "Check for and install available Debian updates, install, and automatically restart? (y/n)? "
        read -t 10 -r response
        if [ "$response" != "${response#[Yy]}" ] ;then
            sudo apt-get -y --allow-unauthenticated upgrade && \
            sudo apt-get autoclean && \
            sudo apt-get autoremove
        fi
    fi
    sudo apt clean && rm -rf -- *.deb* *.gpg* *.py*
}

########################################
########### THE SETUP ##################
########################################
ReposInstaller
PackagesInstaller
Cleanup
installDotfiles
if [[ $(sudo lshw | grep product | head -1) == *"XPS"* ]]; then
    DELL_XPS_TWEAKS
fi

cecho "${white}" "################################################################################"
cecho "${cyan}" "Done!"
cecho "${cyan}" "Please Reboot system!"
