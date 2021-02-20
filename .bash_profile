#!/bin/bash

E_BOLD="\033[1m"

# define colors
C_DEFAULT="\033[m"
C_BK_DEFAULT="\033[m"
C_WHITE="\033[1m"
C_WHITE2="\033[38;5;255m"
C_BLACK="\033[38;2;1;1;1m"
C_RED="\033[31m"
C_RED2="\033[38;2;182;72;17m"
C_GREEN="\033[32m"
C_GREEN2="\033[38;2;53;104;9m"
C_YELLOW="\033[33m"
C_BLUE="\033[34m"
C_PURPLE="\033[35m"
C_CYAN="\033[36m"
C_CYAN2="\033[38;2;44;181;233m"
C_BK_CYAN2="\033[48;2;44;181;233m"
C_LIGHTGRAY="\033[37m"
C_DARKGRAY="\033[38;5;244m"
C_BK_DARKGRAY="\033[48;5;244m"
C_LIGHTRED="\033[1;31m"
C_LIGHTGREEN="\033[1;32m"
C_LIGHTGREEN2="\033[0;32m"
C_BK_LIGHTGREEN2="\033[0;42m"
C_LIGHTYELLOW="\033[1;33m"
C_LIGHTBLUE="\033[1;34m"
C_LIGHTBLUE2="\033[38;5;24m"
C_BK_LIGHTBLUE2="\033[48;5;24m"
C_LIGHTPURPLE="\033[1;35m"
C_LIGHTCYAN="\033[1;36m"
C_ORANGE="\033[38;5;214m"
C_BK_ORANGE="\033[48;5;214m"
C_BG_BLACK="\033[40m"
C_BG_RED="\033[41m"
C_BG_GREEN="\033[42m"
C_BG_YELLOW="\033[43m"
C_BG_BLUE="\033[44m"
C_BG_PURPLE="\033[45m"
C_BG_CYAN="\033[46m"
C_BG_LIGHTGRAY="\033[47m"



export CLICOLOR=1
export LSCOLORS=cxGxFxDxBxegedabagcxcx

C_CUST_LIGHT_BLUE="\e[38;5;027m\]"
TRIANGLE=$'\uE0B0'
LEFT_TRIANGLE=$'\uE0B2'
BRANCH_ICON=$'\uE0A0'
COMMITS_BEHIND_ICON=$'\uF433'
COMMITS_AHEAD_ICON=$'\uF431'
CHECK_MARK=$'\uF00C'

PS1="${C_BK_LIGHTBLUE2}${C_WHITE2}\D{%F}${C_BK_DARKGRAY}${C_LIGHTBLUE2}${TRIANGLE}\
${C_BK_DARKGRAY}${C_BLACK}\t${C_BK_CYAN2}${C_DARKGRAY}${TRIANGLE}\
${E_BOLD}${C_BK_CYAN2}${C_BLACK}\u${C_DEFAULT}${C_BK_DARKGRAY}${C_CYAN2}${TRIANGLE}\
${C_BLACK}\h${C_DEFAULT}${C_DARKGRAY}${TRIANGLE} \
${C_LIGHTGREEN2}\w${C_DEFAULT} \
\$(git_parse_branch)\n"

DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

#--------------------------------user specific variables--------
. $DIR/.exports

#--------------------------------system helper------------------

#kill all processes by name
function killp {
   ps aux | grep $1 | grep -v grep | awk '{print $2}' | xargs kill
}

#--------------------------------common aliases-----------------

alias grep="grep --color=auto"


#--------------------------------homebrew-----------------------

export HOMEBREW_NO_AUTO_UPDATE=1

export HOMEBREW_EDITOR=code

function brew-tap-formulas { 
   brew tap-info --json "$@" | jq -r '.[]|(.formula_names[],.cask_tokens[])' | sort -V 
}
#--------------------------------PATH---------------------------
#forcing to use openssl
#
export PATH="~/Work/fill-queue/build:~/Work/eos/build/bin/:$(brew --prefix openssl)/bin:/usr/local/opt/rabbitmq/sbin:/usr/local/sbin:$PATH"
export LIBRARY_PATH="/usr/local/opt/icu4c/lib:${LIBRARY_PATH}"
#--------------------------------hub----------------------------

#eval "$(hub alias -s)"

#---------------------------------------------------------------

#--------------------------------suppress zsh warning-----------
export BASH_SILENCE_DEPRECATION_WARNING=1

#--------------------------------GitHub-------------------------
ssh-add -K ~/.ssh/github.key 2>/dev/null
export GPG_TTY=$(tty)

#--------------------------------Git----------------------------

git_parse_branch() {
    BRANCH=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    if [[ -n $BRANCH ]]
    then
      GIT_COMMITS_DATA=$(git rev-list --left-right --count origin/${BRANCH}...@)
      COMMITS_BEHIND=$(echo "$GIT_COMMITS_DATA" | cut -f1)
      COMMIT_AHEAD=$(echo "$GIT_COMMITS_DATA" | cut -f2)
      COMMITS_TEXT=${C_RED2}${COMMITS_BEHIND_ICON}${C_BLACK}${COMMITS_BEHIND}
      if (($COMMIT_AHEAD > $COMMITS_BEHIND))
      then
         COMMITS_TEXT=${C_GREEN2}${COMMITS_AHEAD_ICON}${C_BLACK}${COMMIT_AHEAD}
      elif (($COMMIT_AHEAD == $COMMITS_BEHIND))
      then
         COMMITS_TEXT=${C_GREEN2}${CHECK_MARK}
      fi
      echo -e -n "${C_DEFAULT}${C_ORANGE}${LEFT_TRIANGLE}${C_BLACK}${C_BK_ORANGE} ${BRANCH_ICON}${BRANCH} ${COMMITS_TEXT} ${C_DEFAULT}${C_ORANGE}${TRIANGLE}${C_DEFAULT}"
    fi
}

git_delete_branch() {
   echo "deleting $1 branch locally..."
   git branch -D $1
   echo "deleting $1 branch remotely..."
   git push origin --delete $1
}

git_modules_update() {
   git submodule update --init --recursive
}

git_clone() {
   git clone git@github.com:${@}
}

#--------------------------------EOS-----------------------------

sign_nodeos() {
   codesign -f -s $APPLE_ID $HOME/Work/eos/build/bin/nodeos
   codesign -f -s $APPLE_ID $HOME/Work/eos_copy/build/bin/nodeos
}

#--------------------------------buildkite-----------------------

bk() {
   curl -fsSL -H "Authorization: Bearer $BUILDKITE_API_KEY" "https://api.buildkite.com/$1"
}

#--------------------------------docker--------------------------

docker-rm-image() {
   docker images | awk 'NR>1 {print $1 $3}' | grep $1 | awk '{print $2}' | xargs docker rmi
}
