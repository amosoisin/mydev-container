#!/bin/bash
set -euo pipefail

# ログ関数
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

error() {
    log "ERROR: $*" >&2
}

# シンボリックリンク作成関数（エラーハンドリング付き）
create_symlink() {
    local src=$1
    local dst=$2
    local optional=${3:-false}

    if [ ! -e "$src" ]; then
        if [ "$optional" = "true" ]; then
            log "WARN: Source not found (skipped): $src"
            return 0
        else
            error "Source not found: $src"
            return 1
        fi
    fi

    # 親ディレクトリが存在しない場合は作成
    local dst_dir
    dst_dir=$(dirname "$dst")
    if [ ! -d "$dst_dir" ]; then
        mkdir -p "$dst_dir"
        log "Created directory: $dst_dir"
    fi

    # シンボリックリンク作成
    if ln -nfs "$src" "$dst"; then
        log "Linked: $dst -> $src"
        return 0
    else
        error "Failed to create symlink: $dst -> $src"
        return 1
    fi
}

log "=== Starting container initialization ==="

# Claude Code設定
create_symlink /configs/claude/CLAUDE.md "${HOME}/.claude/CLAUDE.md" true

# Zsh設定
create_symlink /configs/zsh/p10k.zsh "${HOME}/.p10k.zsh"
create_symlink /configs/zsh/zshrc "${HOME}/.zshrc"
create_symlink /configs/zsh/myconfig "${HOME}/.oh-my-zsh/custom/plugins/myconfig"

# Neovim設定
create_symlink /configs/nvim.lua "${HOME}/.config/nvim"

# Git設定
create_symlink /configs/git/gitconfig "${HOME}/.gitconfig"

# Gitユーザー設定ファイル作成
if [ -n "${GIT_EMAIL:-}" ] && [ -n "${GIT_USER:-}" ]; then
    cat << EOF > "${HOME}/.gitconfig-user"
[user]
    email = ${GIT_EMAIL}
    name = ${GIT_USER}
EOF
    log "Created Git user config: ${HOME}/.gitconfig-user"
else
    error "GIT_EMAIL or GIT_USER is not set"
fi

# Tmux設定
create_symlink /configs/tmux/tmux.conf "${HOME}/.tmux.conf"

# Zsh履歴ファイル
if [ ! -f "${HOME}/.cache/zsh_history" ]; then
    touch "${HOME}/.cache/zsh_history"
    log "Created zsh history file"
fi
create_symlink .cache/zsh_history "${HOME}/.zsh_history"

log "=== Container initialization completed ==="

# コンテナを起動し続ける
sleep infinity
