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
\$(git-parse-branch)\n"

DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

#--------------------------------math---------------------------
#simple wrapper for math. using bc as it handles big numbers
function c {
   #if there is % in the expression that measn we want division reminder hence no floating point operations
   if [[ -n $(grep "%" <<< "$@") ]]
   then
      SCALE=0
   else
      SCALE=8
   fi
   RESULT=$(bc <<< "scale=$SCALE; ${@}")
   #removing trailing zeros
   RESULT=$(sed 's/0*$//' <<< $RESULT)
   #removing trailing dot
   RESULT=$(sed 's/\.$//' <<< $RESULT)
   #adding leading zero
   RESULT=$(sed 's/^\./0\./' <<< $RESULT)
   echo "$RESULT"
   set +f
}
#set -f have to happen before parameters expansion so doing this in alias
#and unsetting this option inside function c as alias can't be prefixed
alias c='set -f; c'
#--------------------------------user specific variables--------
. $DIR/.exports

#--------------------------------common aliases-----------------

alias grep="grep --color=auto"

#--------------------------------homebrew-----------------------

export HOMEBREW_NO_AUTO_UPDATE=1

export HOMEBREW_EDITOR=code

function brew-tap-formulas { 
   brew tap-info --json "$@" | jq -r '.[]|(.formula_names[],.cask_tokens[])' | sort -V 
}

function brew-update-all {
   brew update && brew upgrade
}

#--------------------------------PATH---------------------------
PATH="~/Work/fill-queue/build:$PATH"
PATH="~/Work/eos/build/bin/:$PATH"
PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
PATH="/usr/local/opt/rabbitmq/sbin:$PATH"
export PATH="/usr/local/sbin:$PATH"

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

git-parse-branch() {
    BRANCH=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    if [[ -n $BRANCH ]]
    then
      if [[ -n $(git checkout | grep "Your branch") ]]
      then
         BRANCH_TRIM=$(sed 's/(HEAD detached at \(.*\))/\1/' <<< $BRANCH)
         if [[ "$BRANCH_TRIM" != "$BRANCH" ]]
         then
            DETACHED_COMMIT=$(git rev-list -n 1 $BRANCH_TRIM)
         fi
         COMMIT_NAME=${DETACHED_COMMIT:-origin/$BRANCH}
         GIT_COMMITS_DATA=$(git rev-list --left-right --count "${COMMIT_NAME}"...@)
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
      fi
      echo -e -n "${C_DEFAULT}${C_ORANGE}${LEFT_TRIANGLE}${C_BLACK}${C_BK_ORANGE} ${BRANCH_ICON}${BRANCH} ${COMMITS_TEXT} ${C_DEFAULT}${C_ORANGE}${TRIANGLE}${C_DEFAULT}"
    fi
}

git-delete-branch() {
   echo "deleting $1 branch locally..."
   git branch -D $1
   echo "deleting $1 branch remotely..."
   git push origin --delete $1
}

git-modules-update() {
   git submodule update --init --recursive
}

git-clone() {
   git clone git@github.com:${@}
}

#autocompletion stuff
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

#--------------------------------EOS-----------------------------

sign-nodeos() {
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

#--------------------------------nvm-----------------------------

# #nvm takes like 2-3 sec to load so skipping its load by default
# #export NVM_DIR="$HOME/.nvm"
# #[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

#--------------------------------transmission--------------------

alias td-start='brew services start transmission-cli'
alias td-stop='brew services stop transmission-cli'
alias td-restart='brew services restart transmission-cli'
alias t-list='transmission-remote -l'
alias t-basicstats='transmission-remote -st'
alias t-fullstats='transmission-remote -si'
alias t-add='transmission-remote -a'
alias t-start='transmission-remote --torrent all --start'

function t-clean {
   DOWNLOAD_DIR=$(cat "/usr/local/var/transmission/settings.json" | jq -r '."download-dir"')
   ID_NAME_MAP=$(t-list | awk '{print $1,$10}' | grep -e "^[0-9]\+" | sed 's/^\([0-9]\{1,\}\)[^[[:space:]]]*[[:space:]]/\1 /')
   while read line
   do
      ID=$(awk '{print $1}' <<< $line)
      NAME=$(awk '{print $2}' <<< $line)
      if [[ -z $(find "${DOWNLOAD_DIR}" -name "${NAME}*") ]]
      then
         transmission-remote -t $ID -r
      fi
   done <<< $ID_NAME_MAP
}