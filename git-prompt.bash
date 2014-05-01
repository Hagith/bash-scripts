        RED="\[\033[0;31m\]"
     YELLOW="\[\033[0;33m\]"
      GREEN="\[\033[0;32m\]"
       BLUE="\[\033[0;34m\]"
  LIGHT_RED="\[\033[1;31m\]"
LIGHT_GREEN="\[\033[1;32m\]"
      WHITE="\[\033[1;37m\]"
 LIGHT_GRAY="\[\033[0;37m\]"
 COLOR_NONE="\[\e[0m\]"

function update_title_bar() {
    case "$TERM" in
    xterm*|rxvt*)
        echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"
        ;;
    esac
}

function parse_git_branch {

  git rev-parse --git-dir &> /dev/null
  git_status="$(git status 2> /dev/null)"
  branch_pattern="On branch ([^${IFS}]*)"
  remote_pattern=".*Your branch is (.*) '"
  diverge_pattern=".*Your branch and (.*) have diverged"
  if [[ ! ${git_status} =~ "working directory clean" ]]; then
    state="${RED}⚡"
  fi
  # add an else if or two here if you want to get more specific
  if [[ ${git_status} =~ ${remote_pattern} ]]; then
    if [[ ${BASH_REMATCH[1]} == "ahead of" ]]; then
      remote="${YELLOW}↑"
    elif [[ ${BASH_REMATCH[1]} == "behind" ]]; then
      remote="${YELLOW}↓"
    fi
  fi
  if [[ ${git_status} =~ ${diverge_pattern} ]]; then
    remote="${YELLOW}↕"
  fi
  if [[ ${git_status} =~ ${branch_pattern} ]]; then
    branch=${BASH_REMATCH[1]}
    echo " (${branch})${remote}${state}"
  fi
}

TITLEBAR="\h (\u) "

function prompt_func() {
    previous_return_value=$?;
    # prompt="${TITLEBAR}${BLUE}[${RED}\w${GREEN}$(__git_ps1)${YELLOW}$(git_dirty_flag)$BLUE]$COLOR_NONE "
    prompt="${TITLEBAR}${BLUE}[${RED}\w${GREEN}$(parse_git_branch)${BLUE}]${COLOR_NONE} "
    if test $previous_return_value -eq 0
    then
        PS1="${prompt}➔  "
    else
        PS1="${prompt}${RED}➔${COLOR_NONE} "
    fi
    update_title_bar
}

PROMPT_COMMAND=prompt_func
