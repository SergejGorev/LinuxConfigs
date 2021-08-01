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
```
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
```
Then clone the repo from Gitlab to the folder:
```
git clone --bare git@gitlab.com:yourname/testrepo.git $HOME/.cfg
```
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


### Fish Config
function fish_greeting
end


### PROMPT ###
# name: sashimi
function fish_prompt
  set -l last_status $status
  set -l cyan (set_color -o cyan)
  set -l yellow (set_color -o yellow)
  set -g red (set_color -o red)
  set -g blue (set_color -o blue)
  set -g dimBlue (set_color -o blue --dim)
  set -g brightBlue (set_color -o brblue)
  set -l green (set_color -o green)
  set -g normal (set_color normal)

  set -l ahead (_git_ahead)
  set -g whitespace ' '
  set -l slash '/'
  
  set -l cwd $brightBlue(prompt_pwd)

  if test $last_status = 0
    # set initial_indicator "$green◆"
    set status_indicator "$normal❯$cyan❯$green❯"
  else
    # set initial_indicator "$red✖ $last_status"
    set status_indicator "$red❯$red❯$red❯"
  end

  if [ (_git_branch_name) ]

    if test (_git_branch_name) = 'master'
      set -l git_branch (_git_branch_name)
      set git_info "$normal git:($red$git_branch$normal)"
    else
      set -l git_branch (_git_branch_name)
      set git_info "$normal git:($blue$git_branch$normal)"
    end

    if [ (_is_git_dirty) ]
      set -l dirty "$yellow ✗"
      set git_info "$git_info$dirty"
    end
  end

  # Notify if a command took more than 5 minutes
  if [ "$CMD_DURATION" -gt 300000 ]
    echo The last command took (math "$CMD_DURATION/1000") seconds.
  end

  echo -n -s $initial_indicator $whitespace $cwd $git_info $whitespace $ahead $status_indicator $whitespace
end

function _git_ahead
  set -l commits (command git rev-list --left-right '@{upstream}...HEAD' ^/dev/null)
  if [ $status != 0 ]
    return
  end
  set -l behind (count (for arg in $commits; echo $arg; end | grep '^<'))
  set -l ahead  (count (for arg in $commits; echo $arg; end | grep -v '^<'))
  switch "$ahead $behind"
    case ''     # no upstream
    case '0 0'  # equal to upstream
      return
    case '* 0'  # ahead of upstream
      echo "$blue↑$normal_c$ahead$whitespace"
    case '0 *'  # behind upstream
      echo "$red↓$normal_c$behind$whitespace"
    case '*'    # diverged from upstream
      echo "$blue↑$normal$ahead $red↓$normal_c$behind$whitespace"
  end
end

function _git_branch_name
  echo (command git symbolic-ref HEAD ^/dev/null | sed -e 's|^refs/heads/||')
end

function _is_git_dirty
  echo (command git status -s --ignore-submodules=dirty ^/dev/null)
end
### PROMPT ###

### bang bang###
function __history_previous_command
  switch (commandline -t)
  case "!"
    commandline -t $history[1]; commandline -f repaint
  case "*"
    commandline -i !
  end
end

function __history_previous_command_arguments
  switch (commandline -t)
  case "!"
    commandline -t ""
    commandline -f history-token-search-backward
  case "*"
    commandline -i '$'
  end
end
### bang bang###

### ABBRIVIATIONS ###
abbr -a la la -A -X --color=always --group-directories-first

### BINDINGS ###
#backwardskill
bind \cH backward-kill-word

# connect to alphagoldmine production algo server
function ag
  ssh root@157.90.24.139
end


# bang bang bindings
bind ! __history_previous_command
bind '$' __history_previous_command_arguments

#>>> conda initialize >>>
set -l f /opt/miniconda3/etc/fish/conf.d/conda.fish
if test -e $f
  source $f
else
  echo $f "does not exist, run 'conda init fish' to initialize the file"
end
# <<< conda initialize END <<<

## copy ##
function copy
    set count (count $argv | tr -d \n)
    if test "$count" = 2; and test -d "$argv[1]"
	set from (echo $argv[1] | trim-right /)
	set to (echo $argv[2])
        command cp -r $from $to
    else
        command cp $argv
    end
end


### ssh ipis
Host rob
        #HostName pppoe_ptm_7_0_d
        HostName 192.168.1.100
        User robot
        Port 666
        IdentityFile ~/.ssh/computa
        IdentitiesOnly yes

Host awscom
    HostName 3.68.105.211
    IdentityFile ~/.ssh/comod_analysis.pem
    IdentitiesOnly yes
    User ubuntu
