# https://github.com/databus23/dotfiles/blob/master/fish/config.fish
alias ssh-no-check='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias scp-no-check='scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

set -g CDPATH ./ ~/workspace/crv/infra-devbox/environments/lab/modules/ ~/workspace/crv/infra-devbox/ ~/

#alias kitchen='cd ~/workspace/crv/infra-devbox/ ;and /home/serkroes/workspace/crv/infra-devbox/vendor/bundle/ruby/2.5.0/bin/kitchen'
# direnv if available
if which direnv 2>&1 >/dev/null
  eval (direnv hook fish)
end