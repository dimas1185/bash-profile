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



#-------------------------------ls------------------------------
export LS_COLORS=$(vivid generate one-dark)

alias ls="ls --color=auto"

#--------------------------------PS-----------------------------
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
   #removing trailing zeros after dot
   RESULT=$(sed 's/\(\.[0-9]*[1-9]\)0*$/\1/' <<< $RESULT)
   #removing trailing dot for float number
   RESULT=$(sed 's/\.$//' <<< $RESULT)
   #adding leading zero to float number
   RESULT=$(sed 's/^\./0\./' <<< $RESULT)
   numfmt --grouping $RESULT
   set +f
}
#set -f have to happen before parameters expansion so doing this in alias
#and unsetting this option inside function c as alias can't be prefixed
alias c='set -f; c'
#--------------------------------user specific variables--------
. $DIR/.exports

#--------------------------------common aliases-----------------

alias grep="grep --color=auto"

#--------------------------------PATH---------------------------
PATH="~/work/leap/build/bin/:$PATH"
export PATH="~/work/cdt/build/bin/:$PATH"

export CDT_BUILD_PATH="~/work/cdt/build/bin"

#---------------------------------------------------------------

#--------------------------------GitHub-------------------------
ssh-add ~/.ssh/id_ed25519 2>/dev/null
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

git-list-tags() {
   git log --tags --simplify-by-decoration --pretty="format:%cs %d" --no-walk | grep -P "(?<=tag: )([A-Za-z0-9\/\.\-_]*)"
}

#autocompletion stuff
[[ -r "/etc/profile.d/bash_completion.sh" ]] && . "/etc/profile.d/bash_completion.sh"

#--------------------------------docker--------------------------

docker-rm-image() {
   IMAGES=$(docker images | awk 'NR>1 {print $1, $3}')
   for var in "$@"
   do
      echo "$IMAGES" | grep "$var" | awk '{print $2}' | xargs docker rmi
   done
}

docker-c-ls() {
   docker container ls --all
}

docker-c-cleanup() {
   docker container ls --all --format "table {{.Names}}" | awk 'NR>1 {print $1}' | xargs docker rm
}

#--------------------------------nvm-----------------------------

# #nvm takes like 2-3 sec to load so skipping its load by default
# #export NVM_DIR="$HOME/.nvm"
# #[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm