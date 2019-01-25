# Simple Bash script for setting up a new Computer (running [X]Ubuntu)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/43713e0b78f547e8912ff05c9350cffb)](https://app.codacy.com/app/mmphego/xubuntu-pkg-installer?utm_source=github.com&utm_medium=referral&utm_content=mmphego/xubuntu-pkg-installer&utm_campaign=Badge_Grade_Dashboard)
[![Build Status](https://travis-ci.com/mmphego/new-computer.svg?branch=master)](https://travis-ci.com/mmphego/new-computer)

My personal system set-up script which installs most of the packages I need on a daily basis after a fresh [X]Ubuntu system install. Added [support for tweaking Dell XPS 15](http://github.com/mmphego/dell-xps-9570-ubuntu-respin/)

What is installed?
-  Basics(git, curl, pinta, gdebi, gparted, sshfs, vim and a couple of other packages)
-  Python-pip and [few modules](pip-requirements.txt)
-  [Docker](https://www.docker.com/)
-  [VSCode](https://code.visualstudio.com) and [Sublime-Text](www.sublimetext.com/3)
-  [Slack](https://slack.com)
-  [Megasync](https://mega.nz)
-  [Gummi](https://github.com/alexandervdm/gummis) and Latex dependencies
-  [Mendeley](https://www.mendeley.com), and etc

## Install from script

```bash
bash -c "`curl -L https://git.io/runme`"
```

### Feedback

Feel free to fork it or send me PR to improve it.
