# Simplest Way to Sync Dotfiles and Config Using Git

Most devs have two or more computers that they use. In my case it is my home Macbook and one in the office. We want to have the same config, keybinding or aliases across those machines.
There are several ways to do it. I tried using symlinks to a folder that is synced through git, but some apps won’t load symlinked files. For example, if you try to symlink `~/.zshrc` then zsh will load as if you don’t have an rc file.
After looking around for a while, I came upon a post in Hackernews about this issue. It led to this article by Atlassian. It is by far the best solution.

## Git Bare
This technique is using `git init --bare` which I have never encountered before. You don’t really need to understand it to use it, but for reference sake, this is what `--help` says.
```
--bare 
Create a bare repository. If GIT_DIR environment is not set, it is set to the current working directory.
```

## Setup
That article is very succinct and you could just follow the steps laid out there. In summary, use these commands to set it up.
git init --bare $HOME/.cfg 
```
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME' config config --local status.showUntrackedFiles no 
echo "alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'" >> $HOME/.bashrc
```
Replace the last `.bashrc` to whatever shell that you are using e.g. in my case it is `.zshrc`.


## Operation
All git operation are permitted, you just have to use config instead of git. For example:
```
config status 
config add ~/.zshrc 
config commit -m "Add vimrc" 
config add ~/.xvimrc 
config commit -m "Add xvimrc"
```
To sync those files with another computer, you need to setup a repo. I recommend using Gitlab as they have free private repos. After creating new repo in Gitlab, you can do:
```
config remote add origin git@gitlab.com:yourname/testrepo.git 
config push -u origin master
```
From this point on, you can treat it like normal git repo. One interesting use case would be to create different branches for different settings that you wanted to use.

## Setting up new machines
Now that you have the first machine set up and syncing nicely, you can start setting up the second machine by first adding this line to .zshrc or .bashrc.
`alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'`
Then clone the repo from Gitlab to the folder:
`git clone --bare git@gitlab.com:yourname/testrepo.git $HOME/.cfg`
From here, you can `pull`, `push`, `merge` and `checkout` to your hearts content.
You really should read the source article since it explains the steps in detail except adding remote repo.





# DWM ==> yay -S dwm-distrotube-git
```
docker install
sudo groupadd docker
sudo usermod -aG docker $USER
gpasswd -a $USER docker
sudo systemctl start docker
newgrp docker
sudo systemctl enable docker
docker run hello-world
```