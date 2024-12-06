# History configuration
HISTSIZE=10000
HISTFILESIZE=10000
HISTFILE=~/.bash_history
HISTCONTROL=ignoredups:erasedups
HISTIGNORE="ls:cd:pwd:exit:date:* --help"

# Enable color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Git branch and status function
git_prompt_info() {
    # Check if in git repo - if not, return empty
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

    # Get branch name
    branch=$(git symbolic-ref HEAD 2>/dev/null | cut -d'/' -f3)
    
    # Initialize indicators
    indicators=""
    
    # Add status indicators - using tput for color codes
    [[ -n $(git status --porcelain 2>/dev/null | grep '^??') ]] && indicators+="$(tput setaf 1)●$(tput sgr0)"  # red for untracked
    [[ -n $(git status --porcelain 2>/dev/null | grep '^.M') ]] && indicators+="$(tput setaf 3)●$(tput sgr0)"  # yellow for modified
    [[ -n $(git status --porcelain 2>/dev/null | grep '^A') ]] && indicators+="$(tput setaf 2)●$(tput sgr0)"   # green for added
    [[ -n $(git rev-list HEAD --not --remotes 2>/dev/null) ]] && indicators+="$(tput setaf 6)↑$(tput sgr0)"    # cyan for unpushed

    # Color branch based on status
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
        printf "$(tput setaf 3)(%s)$(tput sgr0)%s" "$branch" "$indicators"  # yellow if changes
    else
        printf "$(tput setaf 2)(%s)$(tput sgr0)%s" "$branch" "$indicators"  # green if clean
    fi
}

# Virtual environment status function
venv_info() {
    # Check if in virtual environment
    if [[ -n "$VIRTUAL_ENV" ]]; then
        # Extract venv name - everything after the last '/'
        printf "$(tput setaf 5)($(basename $VIRTUAL_ENV))$(tput sgr0) "
    fi
}

# Define color codes using tput
BLUE="$(tput setaf 4)"
GREEN="$(tput setaf 2)"
RESET="$(tput sgr0)"

# Set up prompt with git information
PROMPT_COMMAND='PS1="$(venv_info)${BLUE}\w${RESET} $(git_prompt_info) ${GREEN}➜${RESET} "'

# Docker alias for aider (if you're using it)
alias aider="docker run -it --rm --user \$(id -u):\$(id -g) --volume \$(pwd):/app paulgauthier/aider --openai-api-key \$OPENAI_API_KEY --anthropic-api-key \$ANTHROPIC_API_KEY"

# Source environment variables if the file exists
if [ -f ~/.env ]; then
    source ~/.env
fi

# Enable extended pattern matching
shopt -s extglob

# Ensure window size is updated correctly
shopt -s checkwinsize

# Append to history instead of overwriting
shopt -s histappend

# Save multi-line commands as one command
shopt -s cmdhist

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
