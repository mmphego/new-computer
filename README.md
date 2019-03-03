
# Simple Bash script for setting up a new computer (running [X]Ubuntu)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/43713e0b78f547e8912ff05c9350cffb)](https://app.codacy.com/app/mmphego/xubuntu-pkg-installer?utm_source=github.com&utm_medium=referral&utm_content=mmphego/xubuntu-pkg-installer&utm_campaign=Badge_Grade_Dashboard)
[![Build Status](https://travis-ci.com/mmphego/new-computer.svg?branch=master)](https://travis-ci.com/mmphego/new-computer)
[![LICENCE](https://img.shields.io/github/license/mmphego/new-computer.svg?style=plastic)](https://github.com/mmphego/new-computer/blob/master/LICENSE)

My personal system set-up script which installs most of the packages I need on a daily basis after a fresh [X]Ubuntu system install.
- Added [support for tweaking Dell XPS 15](https://github.com/JackHack96/dell-xps-9570-ubuntu-respin)
- Dotfiles installation
- GitHub GPG and SSH keys installation

## Installation:
On an [X]Ubuntu based distro with admin/sudo rights, run the following and follow the prompts:
```bash
bash -c "$(curl -L https://git.io/runme)"
# That's it
```

Here are some of the things that gets set up:
- Installs [Git](https://github.com/git/git)+[Hub](http://github.com/github/hub/) and configures your [GPG](https://help.github.com/articles/generating-a-new-gpg-key/) and [SSH](https://help.github.com/articles/connecting-to-github-with-ssh/) keys via [api.github.com](api.github.com)
- Installs [Travis-CI](https://github.com/travis-ci/travis.rb) ruby based CLI client for managing Travis builds.
- Installs Python3.7 and [few modules](pip-requirements.txt) and [Docker](https://www.docker.com/) and configures Docker to work without `sudo` .
- Installs 3 text editors/IDE namely:  [VSCode](https://code.visualstudio.com) including [plugins](code_plugins.txt), [Sublime-Text](www.sublimetext.com/3) and [Atom](https://atom.io/).
- Supports for Arduino/IoT development using [Platfomio](https://platformio.org/) library intergrated on VScode and Atom.
- Installs [Slack](https://slack.com) for colabs, [Megasync](https://mega.nz) and [Dropbox](https://www.dropbox.com/) for cloud storage.
- Installs Academic tools such as [Latex](https://www.latex-project.org/get/) including extras,  [Mendeley](https://www.mendeley.com) for research management and, [Zotero](https://www.zotero.org/) for reference management.
- Installs [a collection of scripts and tweaks to make [X]Ubuntu 18.04 run smooth on Dell XPS 15 9570 ](https://github.com/JackHack96/dell-xps-9570-ubuntu-respin), if you are running a [Dell XPS 15](https://www.dell.com/en-us/shop/dell-laptops/xps-15/spd/xps-15-9570-laptop)
  - [Credit:@JackHack96](https://github.com/JackHack96)
- Installs [my dotfiles](https://github.com/mmphego/dot-files) and [my githooks](https://github.com/mmphego/git-hooks)
- [Optional] Installs additional desktop environment: [elementaryOS](https://elementary.io/) and [Ubuntu](http://ubuntu.com/) 

### The script itself

The script is broken up extensively into functions for easier readability and trouble-shooting. Most everything should be self-explanatory.
You can easily add new methods of installations as well.

### Contributing workflow

Here’s how we suggest you go about proposing a change to this project:

1. [Fork this project][fork] to your account.
2. [Create a branch][branch] for the change you intend to make.
3. Make your changes to your fork.
4. [Send a pull request][pr] from your fork’s branch to our `master` branch.

Using the web-based interface to make changes is fine too, and will help you
by automatically forking the project and prompting to send a pull request too.

[fork]: https://help.github.com/articles/fork-a-repo/
[branch]: https://help.github.com/articles/creating-and-deleting-branches-within-your-repository
[pr]: https://help.github.com/articles/using-pull-requests/
