# https://github.com/databus23/dotfiles/blob/master/fish/config.fish
alias ssh-no-check='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias scp-no-check='scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

alias vi=code
alias vim=code

set -g CDPATH ./ ~/workspace/crv/infra-devbox/environments/lab/modules/ ~/workspace/crv/infra-devbox/ ~/ 2>/dev/null

# direnv if available
if which direnv 2>&1 >/dev/null
  eval (direnv hook fish)
end