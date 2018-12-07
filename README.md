# xubuntu-pkg-installer

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/43713e0b78f547e8912ff05c9350cffb)](https://app.codacy.com/app/mmphego/xubuntu-pkg-installer?utm_source=github.com&utm_medium=referral&utm_content=mmphego/xubuntu-pkg-installer&utm_campaign=Badge_Grade_Dashboard)

[![Build Status](https://travis-ci.com/mmphego/xubuntu-pkg-installer.svg?branch=master)](https://travis-ci.com/mmphego/xubuntu-pkg-installer)

Bash script to install everything I need after a fresh Xubuntu system install.

What is installed:
-  Basics(git, curl, pinta, gdebi, gparted, sshfs, vim and a couple of other packages)
-  Python PIP
-  Docker
-  VScode and Sublime-Text
-  Gummi and Latex dependencies
-  Slack
-  Megasync
-  Mendeley

## Usage

```bash
sudo ./installer.sh
```

### How to backup and restore settings and list of installed packages

**Backup**

```sh
mkdir Backup
dpkg --get-selections > ~/Backup/Package.list
sudo cp -R /etc/apt/sources.list* ~/Backup/
sudo apt-key exportall > ~/Backup/Repo.keys
rsync --progress /home/`whoami` /path/to/user/profile/backup/here
```

**Restore**

```sh
rsync --progress /path/to/user/profile/backup/here /home/`whoami`
sudo apt-key add ~/Backup/Repo.keys

# if you are updating you OS, don't forget to update your source.list
# Hint: $ lsb_release -c # to get the codename
sudo cp -R ~/Backup/sources.list* /etc/apt/
sudo apt-get update
sudo apt-get install dselect
sudo dpkg --set-selections < ~/Backup/Package.list
sudo dselect
```

[Source](http://askubuntu.com/a/99151).

**I'm sure there's a better way of doing things, but I prefer using a Hammer and Hammering everything**
