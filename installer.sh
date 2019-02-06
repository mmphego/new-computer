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

cechon() {
  echo -n "${1}${2}${reset}"
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

if [[ -z "${TRAVIS}" ]]; then
    cecho "${red}" "Have you read through the script you're about to run and ";
    cechon "${red}" "understood that it will make changes to your computer? (y/n): ";
    read -r response
    if [[ "${response}" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        CONTINUE=true
        cecho "${blue}" "Please enter some info so that the script can automate the boring stuff."
        read -r -p 'Enter your full name: ' USERNAME
        read -r -p 'Enter your email address: ' USEREMAIL
    else
        cecho "${red}" "Please go read the script, it only takes a few minutes"
        exit 1
    fi
else
    cecho "${yellow}" "Running Continuous Integration.";
    CONTINUE=true
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
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkg}" || true;
        sudo dpkg --configure -a || true;
        sudo apt-get autoclean && sudo apt-get clean;
    done
}

function ReposInstaller {
    cecho "${green}" "Adding APT Repositories."
    Version=$(lsb_release -cs)

    ## Git
    sudo add-apt-repository -y ppa:git-core/ppa || true

    ## Sublime Text
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add - || true
    echo "deb [trusted=yes] https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list || true
    ## Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - || true
    [ -z "${Version}" ] || sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu ${Version} stable"

    ## VSCode
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg || true;
    sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ || true
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list' || true;

    ## Atom
    sudo add-apt-repository -y ppa:webupd8team/atom || true

    ## Video tools
    sudo add-apt-repository -y ppa:maarten-baert/simplescreenrecorder || true
    sudo add-apt-repository -y ppa:openshot.developers/ppa || true

    ## Laptop battery management
    sudo add-apt-repository -y ppa:linuxuprising/apps || true
    sudo add-apt-repository -y ppa:linrunner/tlp || true
    sudo apt-get update -qq
}

## Install few global Python packages
function PythonInstaller {
    cecho "${cyan}" "Installing global Python packages..."
    if [ ! -f "pip-requirements.txt" ]; then
        wget https://raw.githubusercontent.com/mmphego/new-computer/master/pip-requirements.txt
    fi
    InstallThis python-dev python3-dev python3.7
    curl https://bootstrap.pypa.io/get-pip.py | sudo python
    sudo pip install virtualenv
    virtualenv ~/.venv
    source ~/.venv/bin/activate
    pip install -U -r pip-requirements.txt
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
    InstallThis xubuntu-icon-theme \
        xfce4-* \
        xscreensaver \
        xubuntu-restricted-addons \
        xubuntu-restricted-extras \
        xubuntu-icon-theme \
        blackbird-gtk-theme \
        albatross-gtk-theme \
        ubiquity-slideshow-xubuntu \
        xfwm4-themes \
        xfwm4-theme-breeze \
        xfdashboard-plugins
}

function LatexInstaller {
    InstallThis chktex \
        latexmk \
        pandoc \
        texlive-bibtex-extra \
        texlive-extra-utils \
        texlive-font-utils \
        texlive-lang-english \
        texlive-latex-extra \
        texlive-latex-extra \
        texlive-pictures \
        texlive-pstricks \
        texlive-science \
        texlive-xetex
}

function GitInstaller {
    cecho "${cyan}" "Installing Git+Hub..."
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
    cecho "${red}" "#       A collection of scripts and tweaks to make         #"
    cecho "${red}" "#       Ubuntu 18.04 run smooth on Dell XPS 15 9570        #"
    cecho "${red}" "#                                                          #"
    cecho "${red}" "#            DO NOT RUN THIS SCRIPT BLINDLY                #"
    cecho "${red}" "#               YOU'LL PROBABLY REGRET IT...               #"
    cecho "${red}" "#                                                          #"
    cecho "${red}" "#               READ IT THOROUGHLY,                        #"
    cecho "${red}" "#               EDIT TO SUIT YOUR NEEDS AND,               #"
    cecho "${red}" "#               GO VIEW THE SCRIPT HERE!                   #"
    cecho "${red}" "#                                                          #"
    cecho "${red}" "#   https://github.com/mmphego/dell-xps-9570-ubuntu-respin #"
    cecho "${red}" "#                                                          #"
    cecho "${red}" "############################################################"
    echon

    if [[ -z "${TRAVIS}" ]]; then
        cecho "${red}" "Note that some of these changes require a logout/restart to take effect."
        echo -n "Do you want to proceed with tweaking your Dell XPS? (y/n):-> "
        read -r response
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
    if [ -f "code_plugins.txt" ]; then
        while read -r pkg; do
            code --install-extension "${pkg}";
        done < code_plugins.txt
    fi
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

    if [[ -z "${TRAVIS}" ]]; then
        #############################################
        ### Generate ssh keys & add to ssh-agent
        ### See: https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/
        #############################################

        cecho "${cyan}" "Setting up Git..."
        cecho "${green}"  "Generating SSH keys, adding to ssh-agent..."
        git config --global user.name "${USERNAME}"
        git config --global user.email "${USEREMAIL}"
        git config --global push.default simple

        echo "Use default ssh file location, enter a passphrase: "
        # ssh-keygen -t rsa -b 4096 -C "${useremail}"  # will prompt for password
        ssh-keygen -f ~/.ssh/id_rsa -t rsa -N '' -b 4096 -C "${USEREMAIL}" # will NOT prompt for password
        eval "$(ssh-agent -s)"

        # Now that sshconfig is synced add key to ssh-agent and
        # store passphrase in keychain
        ssh-add ~/.ssh/id_rsa

        cecho "${green}" "##############################################"
        cecho "${green}" "### Add SSH and GPG keys to GitHub via API ###"
        cecho "${green}" "##############################################"
        echo
        cecho "${green}" "Adding ssh-key to GitHub (via api.github.com)..."
        echon
        cecho "${red}" "This will require you to login GitHub's api with your username and password "
        cecho "${red}" "No PASSWORDS ARE SAVED."
        cechon "${red}" "Enter Y/N to continue: "
        read -r response
        if [[ "${response}" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            GHDATA="{"\"title"\":"\"$(hostname)"\","\"key"\":"\"$(cat ~/.ssh/id_rsa.pub)"\"}"
            read -r -p 'Enter your GitHub username: ' GHUSERNAME
            gh_retcode=$(curl -s -w "%{http_code}" -u "${GHUSERNAME}" --data "${GHDATA}" https://api.github.com/user/keys)
            if (( "${gh_retcode}" == 201 )); then
                cecho "${cyan}" "GitHub ssh-key added successfully!"
                echo
            else
                cecho "${red}" "Something went wrong."
                cecho "${red}" "You will need to do it manually."
                cecho "${red}" "Open: https://github.com/settings/keys"
                echo
            fi
        fi

        cecho "${green}" "Add GPG-keys to GitHub (via api.github.com)..."
        echon
        cecho "${red}" "This will require you to login GitHub's API with your username and password "
        cechon "${red}" "Enter Y/N to continue: "
        read -r response
        if [[ "${response}" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            # https://developer.github.com/v3/users/gpg_keys/#
            cecho "${green}" "Generating GPG keys, please follow the prompts."
            if [ -f "github_gpg.py" ]; then
                wget https://raw.githubusercontent.com/mmphego/new-computer/master/github_gpg.py
            fi

            if gpg --full-generate-key; then
                MY_GPG_KEY=$(gpg --list-secret-keys --keyid-format LONG | grep ^sec | tail -1 | cut -f 2 -d "/" | cut -f 1 -d " ")
                # native shell
                #gpg --armour --export $(gpg -K --keyid-format LONG | grep ^sec | sed 's/.*\/\([^ ]\+\).*$/\1/') | jq -nsR '.armored_public_key = inputs' | curl -X POST -u "$GITHUB_USER:$GITHUB_TOKEN" --data-binary @- https://api.github.com/user/gpg_keys
                gpg --armor --export "${MY_GPG_KEY}" > gpg_keys.txt
                read -r -p 'Enter your GitHub username: ' GHUSERNAME
                read -s -p 'Enter your GitHub password: ' GHPASSWORD
                if python github_gpg.py -u "${GHUSERNAME}" -p "${GHPASSWORD}" -f ./gpg_keys.txt; then
                    cecho "${cyan}" "GitHub gpg-key added successfully!"
                    git config --global commit.gpgsign true
                    echo
                else
                    cecho "${red}" "Something went wrong."
                    cecho "${red}" "You will need to do it manually."
                    cecho "${red}" "Open: https://github.com/settings/keys"
                    echo
                fi
            else
                cecho "${red}" "gpg2 is not installed"
            fi
            rm -rf gpg_keys.txt || true;
        fi
    fi
}

function installDotfiles {
    #############################################
    ### Install dotfiles repo
    #############################################
    if [[ -z "${TRAVIS}" ]]; then
        cechon "${red}" "Do you want to clone and install dotfiles? (y/n)"
        read -r response
        if [[ "${response}" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            wget https://github.com/mmphego/dot-files/archive/master.zip
            unzip master.zip
            rsync -uar --delete-after dot-files-master/{.,}* "${HOME}"
            cd "${HOME}" || true;
            bash .dotfiles/.dotfiles_setup.sh install
            cd .. || true;
            find ~/.config/ *.xml -type f -prune | while read -r FILE;
                do sed -i "s/mmphego/${USER}/g" "${FILE}";
            done
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
        gnome-calculator ethtool vnstat

    ### Fun tools
    InstallThis cowsay fortune-mod

    # Packages for xUbuntu
    if [[ $(dpkg -l '*buntu-desktop' | grep ^ii | cut -f 3 -d ' ') == *"xubuntu"* ]]; then
        xUbuntuPackages
    fi

    ### Productivity tools
    InstallThis axel \
        bzip2 \
        chromium-browser \
        colordiff \
        coreutils \
        docker-ce \
        file \
        gawk \
        gnupg2 \
        grep \
        gzip \
        htop \
        jq \
        lzip \
        openssh-server \
        rar \
        rsync \
        sed  \
        sqlite3 \
        terminator \
        vim \
        virtualbox \
        xz-utils \

    GitInstaller
    TravisClientInstaller

    # Python Packages
    PythonInstaller

    ### Dev Editors and tools
    InstallThis code
    if [ ! -f "code_plugins.txt" ]; then
        wget https://raw.githubusercontent.com/mmphego/new-computer/master/code_plugins.txt
    fi
    VSCodeSetUp;
    InstallThis sublime-text
    AtomInstaller
    if command -v platformio >/dev/null ;then
        # Arduino hot fixes
        # See: https://docs.platformio.org/en/latest/faq.html#id15
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
    if [[ -z "${TRAVIS}" ]]; then
        cechon "${red}" "Check for and install available Debian updates, install, and automatically restart? (y/n)?: "
        read -r response
        if [ "$response" != "${response#[Yy]}" ] ;then
            sudo apt-get -y --allow-unauthenticated upgrade && \
            sudo apt-get autoclean && \
            sudo apt-get autoremove
        fi
    fi
    sudo apt clean && rm -rf -- *.deb* *.gpg* *.py*

    cecho "${white}" "################################################################################"
    cecho "${cyan}" "Done!"
    if [[ -z "${TRAVIS}" ]]; then
        cechon "${cyan}" "Please Reboot system! (y/n): "
        read -t 10 -r response
        if [ "$response" != "${response#[Yy]}" ] ;then
            sudo shutdown -r now
        fi
    fi
}

########################################
########### THE SETUP ##################
########################################
cecho "${green}" "Running package updates..."
sudo apt-get update -qq
sudo dpkg --configure -a || true;
cecho "${green}" "Installing wget curl and gdebi as requirements!"
InstallThis wget curl gdebi

ReposInstaller
PackagesInstaller
installDotfiles
if [[ $(sudo lshw | grep product | head -1) == *"XPS 15"* ]]; then
    DELL_XPS_TWEAKS
fi
Cleanup

