# https://github.com/databus23/dotfiles/blob/master/fish/config.fish
alias ssh-no-check='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias scp-no-check='scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

# direnv if available
if which direnv 2>&1 >/dev/null
  eval (direnv hook fish)
end