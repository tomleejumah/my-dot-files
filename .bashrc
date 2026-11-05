#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export EDITOR=nvim 
export VISUAL=nvim

alias ls='ls --color=auto'
alias grep='grep --color=auto'
#PS1='[\u@\h \W]\$ '

# ==========================================
# 1. HISTORY SETTINGS
# ==========================================
# Avoid recording consecutive duplicate entries or entries starting with spaces
HISTCONTROL=ignoreboth
# Append to the history file rather than overwriting it
shopt -s histappend                # don't overwrite history on exit

# Shell options
shopt -s autocd                    # type a dir name to cd into it
shopt -s cdspell                   # fix minor cd typos
shopt -s checkwinsize
# Increase limits (default is often 500)
HISTSIZE=5000
HISTFILESIZE=10000
# Store execution date and time format in history
HISTTIMEFORMAT="%F %T "

# ==========================================
# 2. CUSTOM COLORFUL PROMPT (PS1)
# ==========================================
# Format: [User@Host WorkingDirectory]$
# Green username/host, Blue directory, resets color at the prompt
PS1='\[\e[32m\]┌──(\[\e[94;1m\]\u\[\e[94m\]@\[\e[94m\]\h\[\e[0;32m\])-[\[\e[38;5;46;1m\]\w\[\e[0;32m\]] [\[\e[32m\]$?\[\e[32m\]]\n\[\e[32m\]╰─\[\e[94;1m\]✗ \[\e[0m\]'

# ==========================================
# 3. USEFUL ALIASES (SHORTCUTS)
# ==========================================
# Navigation simplifiers
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Colorize default commands for readability
alias ls="ls --color=auto"
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"

# Safety nets (prompts for confirmation before destroying files)
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

# Listing shortcuts
alias ll="ls -alF"   # Detailed layout showing hidden files
alias la="ls -A"     # List almost all files (excludes . and ..)
alias l="ls -CF"     # Multi-column layout

#shortcuts
alias studio="android-studio &>/dev/null &"
alias gc="git commit -m"
alias gb="git branch"
alias gp="git push"
alias ga="git add ."
alias gs="git status"

# Quick config reloads
alias reload="source ~/.bashrc"

# ==========================================
# 4. ENVIRONMENT VARIABLES
# ==========================================
#export EDITOR="nano"   # Sets default text editor (change to vim if preferred)

# Append local binary directories to your system path if they exist
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
export PATH

# ==========================================
# 5. CUSTOM FUNCTIONS
# ==========================================
# Create a new directory and enter it immediately
# mkcd() {
  #  mkdir -p "$1"
   #cd "$1"
#}

# Quick extraction tool for multiple archive formats
extract() {
    if [ -f "$1" ] ; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# camcap() {
    # local outfile="$HOME/Pictures/DCIM/snap_$(date +%Y%m%d_%H%M%S).jpg"
    # ffmpeg -f v4l2 -video_size 640x480 -i /dev/video0 -vframes 1 "$outfile"
    # echo "Saved snapshot to $outfile"
# }
# alias camera='camcap'


export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME/bin:$PNPM_HOME:$PATH"

# Load private environment variables
if [[ -f "$HOME/.config/secrets/env" ]]; then
    source "$HOME/.config/secrets/env"
fi
alias config="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
