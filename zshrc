# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/mitcc/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes

#ZSH_THEME="ys"
# ZSH_THEME="powerlevel9k/powerlevel9k"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8


alias mv='mv -i'
alias cp='cp -i'
alias grep='grep -E --color'
alias df='df -h'
alias vmstat='vm_stat'

alias lstr='ls -tr'
alias lsl='ls -lrt'
alias lm='ls -al|more'
alias cls='printf "\033c"'
alias wh='where'
alias h='cd $HOME'
alias ch='cd $HOME && printf "\033c"'
alias hc='cd $HOME && printf "\033c"'
alias dl='cd $HOME/Downloads'
alias algo='cd $HOME/code/AlgoSolutions'
alias code='cd $HOME/code'
alias des='cd $HOME/Desktop'
alias doc='cd $HOME/Documents'
alias res='cd $HOME/Resources'

alias vi='nvim'
alias vimapp='open -a MacVim.app'

alias py='python'
alias py3='python3'
alias pip3='python3 -m pip'
alias calc='python3 -ic "from math import *; from random import *"'

alias gicd='git icdiff'
alias gdh='git diff HEAD'

alias find_large50="sudo du -a / | sort -n -r | head -n 50"

alias ocb='ocamlbuild'

alias ytd-aria2c='youtube-dl --external-downloader aria2c --external-downloader-args "-x 16  -k 1M"'

alias aria2c-multi='aria2c -s16 -x16 -k1M'

#pon () {
#    export http_proxy="http://127.0.0.1:1087/"
#    export https_proxy="http://127.0.0.1:1087/"
#    export ftp_proxy="http://127.0.0.1:1087/"
#}
pon () {
    export http_proxy="http://127.0.0.1:58591/"
    export https_proxy="http://127.0.0.1:58591/"
    export ftp_proxy="http://127.0.0.1:58591/"
}
poff () {
    unset http_proxy
    unset https_proxy
    unset ftp_proxy
}
# charles proxy
pch () {
    export http_proxy="http://127.0.0.1:8888/"
    export https_proxy="http://127.0.0.1:8888/"
    export ftp_proxy="http://127.0.0.1:8888/"
}


####################### Java Configuration ########################
# 设置 JDK 8
export JAVA_8_HOME=`/usr/libexec/java_home -v 1.8`
# 设置 JDK 11
export JAVA_11_HOME=`/usr/libexec/java_home -v 11`
# 设置 JDK 17
export JAVA_17_HOME=`/usr/libexec/java_home -v 17`

# 默认JDK 8
export JAVA_HOME=$JAVA_8_HOME

# alias命令动态切换JDK版本
alias jdk8="export JAVA_HOME=$JAVA_8_HOME"
alias jdk11="export JAVA_HOME=$JAVA_11_HOME"
alias jdk17="export JAVA_HOME=$JAVA_17_HOME"
####################### Java end ########################

# diff-so-fancy
export DIFF_SO_FANCY_HOME=~/code/tool/diff-so-fancy
export PATH=$PATH:$DIFF_SO_FANCY_HOME

# Scala
SCALA_HOME=/usr/local/scala
export PATH=$PATH:$SCALA_HOME/bin

# gradle
export GRADLE_HOME=/Users/mitcc/Servers/gradle
export PATH=$PATH:$GRADLE_HOME/bin

export PATH=$PATH:/usr/local/mysql/bin

# Go
export GOPATH=/Users/mitcc/code/Go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

# Rust
export PATH=$PATH:$HOME/.cargo/bin

# ruby
export PATH="/usr/local/opt/ruby/bin:$PATH"

# openresty or nginx
export PATH=/usr/local/openresty/nginx/sbin:$PATH

# rabbitmq
export PATH=$PATH:/usr/local/sbin

# curl
export PATH="/usr/local/opt/curl/bin:$PATH"

# laravel
export PATH=$PATH:$HOME/.composer/vendor/bin

# php7
export PATH=/usr/local/php5/bin:$PATH
export PATH=/usr/local/php5/sbin:$PATH

# HCatalog
export HCAT_HOME=/usr/local/opt/hive/libexec/hcatalog

# Homebrew 关闭自动更新
export HOMEBREW_NO_AUTO_UPDATE=true
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles

# thefuck
eval $(thefuck --alias)

# autojump
[ -f /usr/local/etc/profile.d/autojump.sh  ] && . /usr/local/etc/profile.d/autojump.sh

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# zsh-git-prompt
# change theme from ys.zsh-theme to zsh-git-prompt
GIT_PROMPT_EXECUTABLE="haskell"
source ~/code/Haskell/zsh-git-prompt/zshrc.sh
PROMPT='
%{$terminfo[bold]$fg[blue]%}#%{$reset_color%} \
%(#,%{$bg[yellow]%}%{$fg[black]%}%n%{$reset_color%},%{$fg[cyan]%}%n)\
%{$fg[white]%}@\
%{$fg[green]%}%m\
%{$terminfo[bold]$fg[yellow]%}%~%{$reset_color%}\
$(git_super_status) \
%{$fg[white]%}[%*] $exit_code
%{$terminfo[bold]$fg[red]%}$ %{$reset_color%}'

# opam configuration
test -r /Users/mitcc/.opam/opam-init/init.zsh && . /Users/mitcc/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# zsh-autosuggestions
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# zsh-syntax-highlighting(must be at end of .zshrc)
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
