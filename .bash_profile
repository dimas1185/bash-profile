# define colors

C_DEFAULT="\[\033[m\]"

C_WHITE="\[\033[1m\]"

C_BLACK="\[\033[30m\]"

C_RED="\[\033[31m\]"

C_GREEN="\[\033[32m\]"

C_YELLOW="\[\033[33m\]"

C_BLUE="\[\033[34m\]"

C_PURPLE="\[\033[35m\]"

C_CYAN="\[\033[36m\]"
C_CYAN2="\[\033[38;5;051m\]"

C_LIGHTGRAY="\[\033[37m\]"

C_DARKGRAY="\[\033[38;5;244m\]"

C_LIGHTRED="\[\033[1;31m\]"

C_LIGHTGREEN="\[\033[1;32m\]"
C_LIGHTGREEN2="\[\033[0;32m\]"

C_LIGHTYELLOW="\[\033[1;33m\]"

C_LIGHTBLUE="\[\033[1;34m\]"
C_LIGHTBLUE2="\[\033[38;5;24m\]"

C_LIGHTPURPLE="\[\033[1;35m\]"

C_LIGHTCYAN="\[\033[1;36m\]"

C_ORANGE="\[\033[38;5;214m\]"

C_BG_BLACK="\[\033[40m\]"

C_BG_RED="\[\033[41m\]"

C_BG_GREEN="\[\033[42m\]"

C_BG_YELLOW="\[\033[43m\]"

C_BG_BLUE="\[\033[44m\]"

C_BG_PURPLE="\[\033[45m\]"

C_BG_CYAN="\[\033[46m\]"

C_BG_LIGHTGRAY="\[\033[47m\]"



export CLICOLOR=1

export LSCOLORS=cxGxFxDxBxegedabagcxcx

C_CUST_LIGHT_BLUE="\[\033[38;5;027m\]"
#\[\033[38;5;128m\]

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}


PS1="${C_LIGHTBLUE2}\D{%F}${C_DEFAULT} ${C_DARKGRAY}\t${C_DEFAULT} ${C_CYAN2}\u${C_DEFAULT}@\h:${C_LIGHTGREEN2}\w${C_DEFAULT}${C_ORANGE}\$(parse_git_branch)${C_DEFAULT}\n$ "

#--------------------------------common aliases-----------------

alias grep="grep --color=auto"


#--------------------------------homebrew-----------------------

export HOMEBREW_NO_AUTO_UPDATE=1

export HOMEBREW_EDITOR=code

#---------------------------------------------------------------



#--------------------------------hub----------------------------

#eval "$(hub alias -s)"

#---------------------------------------------------------------

#--------------------------------suppress zsh warning-----------
export BASH_SILENCE_DEPRECATION_WARNING=1

#--------------------------------GitHub-------------------------
ssh-add -K ~/.ssh/github.key 2>/dev/null
export GPG_TTY=$(tty)

