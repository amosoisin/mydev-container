#!/bin/sh

# for claude code
ln -nfs /configs/claude/CLAUDE.md "${HOME}/.claude/CLAUDE.md"

# for zsh
ln -nfs /configs/zsh/p10k.zsh "${HOME}/.p10k.zsh"
ln -nfs /configs/zsh/zshrc "${HOME}/.zshrc"
ln -nfs /configs/zsh/myconfig "${HOME}/.oh-my-zsh/custom/plugins/myconfig"

# for nvim
ln -nfs /configs/nvim.lua "${HOME}/.config/nvim"

# for git
ln -nfs /configs/git/gitconfig "${HOME}/.gitconfig"
cat << EOF > ~/.gitconfig-user
[user]
    email = ${GIT_EMAIL}
    name = ${GIT_USER}
EOF

# for tmux
ln -nfs /configs/tmux/tmux.conf "${HOME}/.tmux.conf"

if [ ! -f "${HOME}/.cache/zsh_history" ]; then
	touch "${HOME}/.cache/zsh_history"
fi
ln -nfs .cache/zsh_history "${HOME}/.zsh_history"

sleep infinity
