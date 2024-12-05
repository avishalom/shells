# Add to your ~/.zshrc

# Keep existing prompt configuration
setopt PROMPT_SUBST
autoload -U colors && colors
PROMPT='%F{blue}%~%f %F{green}➜%f '
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '%F{magenta}(%b)%f'
RPROMPT='${vcs_info_msg_0_}'

# History configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

# Enable magic space
bindkey ' ' magic-space


git_prompt_info() {
    # Check if in git repo - if not, return empty
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

    # Get branch name
    branch=$(git symbolic-ref HEAD 2>/dev/null | cut -d'/' -f3)
    
    # Initialize indicators
    indicators=""
    
    # Add status indicators
    [[ -n $(git status --porcelain 2>/dev/null | grep '^??') ]] && indicators+="%F{red}●%f"
    [[ -n $(git status --porcelain 2>/dev/null | grep '^.M') ]] && indicators+="%F{yellow}●%f"
    [[ -n $(git status --porcelain 2>/dev/null | grep '^A') ]] && indicators+="%F{green}●%f"
    [[ -n $(git rev-list HEAD --not --remotes 2>/dev/null) ]] && indicators+="%F{cyan}↑%f"
    
    # Color branch based on status
    branch_color="green"
    [[ -n $(git status --porcelain 2>/dev/null) ]] && branch_color="yellow"
    
    echo " %F{$branch_color}($branch)%f$indicators"
}

# Set the prompt
PROMPT='%F{blue}%~%f$(git_prompt_info) %F{green}➜%f '

alias aider="docker run -it --rm --user $(id -u):$(id -g) --volume $(pwd):/app paulgauthier/aider --openai-api-key $OPENAI_API_KEY --anthropic-api-key $ANTHROPIC_API_KEY"
source ~/.env
