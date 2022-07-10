# general stuff
export EDITOR=vim
export HISTIGNORE="pwd:ls:cd"
export HISTCONTROL=ignoreboth
export HISTFILESIZE=150000
export HISTSIZE=150000
export HISTTIMEFORMAT="%D %I:%M "
export PAGER=less
export LESS='-R -i -g'
export GREP_COLORS='1;37;41'

# Color man pages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;38;5;74m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[38;5;246m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[04;38;5;146m'

for files in ~/{.aliases,.functions,.kubectl_aliases,.vimrc}; do
  if [[ -r "$files" ]] && [[ -f "$files" ]]; then
    # shellcheck disable=SC1090
    source "$files"
  fi
done

PS1="\W \\$ "

source /etc/profile.d/bash_completion.sh

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

source /opt/kube-ps1/kube-ps1.sh
export KUBE_PS1_SYMBOL_ENABLE=false
PS1='[\W $(kube_ps1)] \n\$ '

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
alias krew="kubectl krew"

set -o vi
alias vi="vim"
alias reload="source ~/.bashrc"
source /etc/profile.d/bash_completion.sh

source <(kubectl completion bash)
alias k='kubectl'
complete -F __start_kubectl k
export do='--dry-run=client -o yaml'

if [ -f $HOME/.kube/config ]; then
  export KUBECONFIG_HOME=$HOME/.kube
  export KUBECONFIG=$( ls $HOME/.kube/*.cfg | cut -d/ -f4 | xargs -I {} echo $KUBECONFIG_HOME/{} | tr '\n' ':' )
  kubectl config view --flatten >| $HOME/.kube/config
  export KUBECONFIG=$HOME/.kube/config
  chmod 600 $HOME/.kube/config
  kubectl config-cleanup --clusters --users --print-removed -o=jsonpath='{ range.contexts[*] }{ .context.cluster }{"\n"}' -t 2 | xargs -I {} rm -f ~/.kube/{}.cfg
fi

alias ke="kubectl explain"
alias ker="kubectl explain --recursive"
alias kns='kubens'
alias kctx='kubectx'

alias stern="stern --tail 10 --since 5m"

alias argocd='argocd --grpc-web'

alias crossplane='kubectl crossplane'

set_terminal_title $ENVIRONMENT

########
## Below added by scripts

