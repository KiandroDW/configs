#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

command -v lsd > /dev/null && alias ls='lsd --group-dirs first'
command -v lsd > /dev/null && alias tree='lsd --tree'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'

export EDITOR="nvim"

export MANPAGER="manpager"

# Define Powerline symbols
PS_SYMBOL=''
SLASH_SYMBOL=''
GIT_BRANCH_SYMBOL=''

# Define colors
RESET='\[\033[0m\]'
TEXT='\[\033[30m\]'
DARK_BLUE='\[\033[34m\]'
DARK_BLUE_BG='\[\033[44m\]'
GREEN='\[\033[32m\]'
GREEN_BG='\[\033[42m\]'
LIGHT_BLUE='\[\033[36m\]'
LIGHT_BLUE_BG='\[\033[46m\]'
WHITE='\[\033[37m\]'
WHITE_BG='\[\033[47m\]'
YELLOW='\[\033[33m\]'
YELLOW_BG='\[\033[43m\]'

FULL_GREEN='\[\033[38;5;34m\]'
FULL_RED='\[\033[38;5;196m\]'

# Function to get the current Git branch
parse_git_branch() {
  git branch 2>/dev/null | sed -n 's/* \(.*\)/\1/p'
}

parse_git_added() {
  git status --short 2>/dev/null | grep -c "^[^ ?]"
}

parse_git_not_added() {
  git status --short 2>/dev/null | grep -c "^[ ?]"
}

get_parent_path() {
  local full_path="$(pwd)"
  local parent_path="$(dirname "$full_path")"

  # Ensure the parent path is displayed correctly
  if [[ "$parent_path" == "$HOME" ]]; then
    parent_path="~"
  elif [[ "$parent_path" == "$HOME"* ]]; then
    parent_path="~${parent_path#"$HOME"}"
  fi

  echo "$parent_path"
}


# Function to generate the prompt dynamically
set_bash_prompt() {
  local venv_part=""

  if [[ "$VIRTUAL_ENV" != "" ]]; then
	  venv_part="${WHITE_BG}${TEXT} $(basename "$VIRTUAL_ENV") ${RESET}${GREEN_BG}${WHITE}${PS_SYMBOL}${RESET}"
  fi

  local user_part="${GREEN_BG}${TEXT} \u ${RESET}"

  local user_path_arrow=""
  local path_part=""
  local cwd_part=""
  local cwd_git_arrow=""
  local git_part=""

  local full_path="$(get_parent_path)"
  local cwd="\W"

  local git_branch=$(parse_git_branch)
  local git_added=$(parse_git_added)
  local git_not_added=$(parse_git_not_added)

  local git_text=""

  if (( "$git_added" != 0 )); then
	if (( "$git_not_added" != 0 )); then
	  git_text="${git_branch} ${FULL_GREEN} ${git_added} ${FULL_RED}󱇨 ${git_not_added}"
	else
	  git_text="${git_branch} ${FULL_GREEN} ${git_added}"
	fi
  else
	if (( "$git_not_added" != 0 )); then
	  git_text="${git_branch} ${FULL_RED}󱇨 ${git_not_added}"
	else
	  git_text="${git_branch}"
	fi
  fi

  if [[ "$PWD" != "$HOME" && "$PWD" != "/" ]]; then
    path_part="${DARK_BLUE_BG}${TEXT} ${full_path} ${RESET}${DARK_BLUE}${LIGHT_BLUE_BG}${SLASH_SYMBOL}${RESET}"
	user_path_arrow="${GREEN}${DARK_BLUE_BG}${PS_SYMBOL}${RESET}"
  	cwd_part="${LIGHT_BLUE_BG}${TEXT} ${cwd} ${RESET}"

  	if [[ -n "$git_branch" ]]; then
      git_part="${YELLOW_BG}${TEXT} ${GIT_BRANCH_SYMBOL} ${git_text} ${RESET}${YELLOW}${PS_SYMBOL}${RESET}"
	  cwd_git_arrow="${LIGHT_BLUE}${YELLOW_BG}${PS_SYMBOL}${RESET}"
  	else
	  cwd_git_arrow="${LIGHT_BLUE}${PS_SYMBOL}${RESET}"
  	fi

  else
	user_path_arrow="${GREEN}${DARK_BLUE_BG}${PS_SYMBOL}${RESET}"
  	cwd_part="${DARK_BLUE_BG}${TEXT} ${cwd} ${RESET}"

  	if [[ -n "$git_branch" ]]; then
      git_part="${YELLOW_BG}${TEXT} ${GIT_BRANCH_SYMBOL} ${git_text} ${RESET}${YELLOW}${PS_SYMBOL}${RESET}"
	  cwd_git_arrow="${DARK_BLUE}${YELLOW_BG}${PS_SYMBOL}${RESET}"
  	else
	  cwd_git_arrow="${DARK_BLUE}${PS_SYMBOL}${RESET}"
  	fi

  fi

  PS1="${venv_part}${user_part}${user_path_arrow}${path_part}${cwd_part}${cwd_git_arrow}${git_part}${RESET} "
}

# Set the prompt command
PROMPT_COMMAND=set_bash_prompt


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
. "$HOME/.cargo/env"

# targz
alias untar='tar -xvf'
alias maketar='tar -czf'

# gcc
alias gcc="gcc -Wall -Wextra -Wpedantic"
alias gccd="gcc -Wall -Wextra -Wpedantic -O0 -g"
alias gccr="gcc -Wall -Wextra -Wpedantic -O3"

# memcheck
alias memcheck="valgrind --leak-check=full --track-origins=yes"

# create and enter directory
dc() {
    if ! [[ -d "$1" ]]; then
        mkdir "$1"
    fi
    cd "$1" || return
}
