# Adam Monsen's Bourne Again SHell config file. See
# → bash(1) manpage
# → http://www.gnu.org/software/bash/
# → http://www.tldp.org/LDP/abs/html/

# Source global definitions
if [[ -f /etc/bashrc ]]; then
    source /etc/bashrc
fi

export ANSIBLE_NOCOWS=1
export CVSIGNORE='*.swp *.pyc'
export CVS_RSH=ssh
export EDITOR=vim
export GREP_OPTIONS="--color=auto"
# from http://www.caliban.org/bash/index.shtml
export HISTIGNORE='ls:exit:[bf]g'
export HISTSIZE=10000
# don't put duplicate lines in the history. See bash(1) for more options
# ... and ignore same sucessive entries.
export HISTCONTROL=ignoreboth
export MAIL=/var/mail/$USER
export DEBEMAIL=haircut@gmail.com
export DEBFULLNAME="Adam Monsen"
export DEBSIGN_KEYID=836F29C0
# 'j' is awesome. Use 'j PATTERN' to jump between directories you have
# recently visited. See https://github.com/rupa/j2
DIRJUMP_BASE=$HOME/git/meonkeys/j2
export JPY=$DIRJUMP_BASE/j.py

# (from Ubuntu default .bashrc)
# make less more friendly for non-text input files, see lesspipe(1)
[[ -x /usr/bin/lesspipe ]] && eval "$(lesspipe)"

# stolen from pathmunge() in /etc/profile on FC4 (and modified)
path_prepend () {
    echo $PATH | /bin/egrep -q "(^|:)$1($|:)" || PATH=$1:$PATH
}

path_prepend /usr/sbin
path_prepend $HOME/bin

unset path_prepend

# Only do the following during an interactive prompt.
# Another way to check if the shell is interactive is a [[ -t 0 ]] test, which
# checks if file descriptor zero (stdin) is open and connected to a terminal.
# This may be preferrable if the environment variables are not reliable.
[[ -z "$PS1" ]] && return

# make C-s work in Vim (Command-T open in horizonal split)
# http://stackoverflow.com/a/13648667/156060
stty start undef stop undef

alias f="find . | grep"
alias ls='ls -F --col'
# this is DEFINITELY my most often-used command
alias s='cd ..'
# make a temp dir, then immediately cd into it
alias mktd='tdir=`mktemp -d` && cd $tdir'

# echo public IP address
# see http://unix.stackexchange.com/questions/22615/how-can-i-get-my-external-ip-address-in-bash/81699#81699
# alternative 1: curl http://canhazip.com
# alternative 2: curl http://icanhazip.com
alias wanip='dig +short myip.opendns.com @resolver1.opendns.com'

# list contents right after changing directories
cd() {
  if [[ "$1" ]]
  then builtin cd "$1" && ls
  else builtin cd && ls
  fi
}

# make a directory, then immediately cd into it
mkcd() {
  if [[ "$1" ]]
  then mkdir -p "$1" && cd "$1"
  fi
}

# vw: vim a file on PATH (with TAB-completion). mneumonic: vim `whereis X`
function _vw_comp() {
  local cur
  cur=$(_get_cword)
  COMPREPLY=( $( compgen -c -- $cur ) )
  return 0
}
complete -F _vw_comp vw
function vw() {
  vim $(type -P "$@")
}

# Serve all files in current directory tree via HTTP.
# See also: https://gist.github.com/meonkeys/6eaa7d87c9cea9ace557
function http() {
  python -m SimpleHTTPServer 8000
}

# Enable tab completion for SSH hosts in Bash history
# from http://www.commandlinefu.com/commands/view/8562/enable-tab-completion-for-known-ssh-hosts
complete -W "$(echo $(grep '^ssh ' ~/.bash_history | sort -u | sed 's/^ssh //'))" ssh

# correct minor errors in 'cd' commands
shopt -s cdspell
# good for double-checking history substitutions
shopt -s histverify

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*|screen*)
  PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
  ;;
*)
  ;;
esac

# Configure Git bits in prompt. See /usr/lib/git-core/git-sh-prompt
# or http://git-scm.com/book/en/v2/Git-in-Other-Environments-Git-in-Bash
GIT_PS1_SHOWDIRTYSTATE=y
GIT_PS1_SHOWSTASHSTATE=y
GIT_PS1_SHOWUNTRACKEDFILES=y
GIT_PS1_SHOWUPSTREAM=auto

# ~ the Emotiprompt(TM) ~
# idea came from: http://linuxgazette.net/122/lg_tips.html#tips.1
smiley() {
  err=$?
  if [[ $err == 0 ]]
  then echo ':)'
  else echo ":( $err"
  fi
}
PS1='$(smiley) [\u@\h \W$(__git_ps1 " <%s>")]\$ '

# Search process tables for running processes. Enhanced pgrep, more or less.
p() {
    prog=$1
    found=`pgrep $prog`
    # command name width
    if [[ ! -z "$2" ]]
    then
        cmdwide='cmd -ww'
    else
        cmdwide='comm'
    fi
    if [[ ! -z "$prog" ]] && [[ ! -z "$found" ]]
    then
        ps -o user,pid,ppid,%cpu,%mem,vsz:7,rss:6,stat,$cmdwide -p `pgrep $prog`
    fi
}

# Grep for running processes, show full command lines. mneumonic: pgrep wide
pw() {
    p "$1" show_wide_command_line
}

# enable programmable completion features (you don't need to enable
# this if it is already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [[ -f /etc/bash_completion ]] && [[ -z "$BASH_COMPLETION" ]]; then
    source /etc/bash_completion
fi
source $DIRJUMP_BASE/j.sh
