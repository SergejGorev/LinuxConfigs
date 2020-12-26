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
