# Docker開発環境

<!-- TODO(human): プロジェクトの概要を記述してください
- このDocker環境は、Neovimを中心とした統合開発環境です
- 主に組込みlinuxのcとbash、pythonの開発を行いますが、それ以外の言語の開発も行います。
- 最近はプライベートでclaude codeを使用しますが、会社では使用しません。
- ホストOSを汚さず、再現可能な開発環境を実現します。
- 常にターミナルを使用して開発を行います。
- モダンな開発環境を心がけているため、頻繁に変更を行います。
-->

## 📋 目次

- [機能](#機能)
- [前提条件](#前提条件)
- [クイックスタート](#クイックスタート)
- [環境の詳細](#環境の詳細)
- [カスタマイズ](#カスタマイズ)
- [トラブルシューティング](#トラブルシューティング)

## ✨ 機能

### 開発ツール
- **エディタ**: Neovim (最新版・ソースビルド)
- **シェル**: Zsh + Oh My Zsh + Powerlevel10k
- **ターミナルマルチプレクサ**: Tmux
- **バージョン管理**: Git + Lazygit
- **コンテナツール**: Docker (Docker-out-of-Docker構成)

### プログラミング言語環境
- **Rust**: rustup + cargo (ripgrep, fd-find, eza, bat, zoxide)
- **Go**: golang-go (lazygit, fzf, docker-language-server)
- **Node.js**: n (最新版) + npm
- **Python**: Python 3 + pip

### Language Servers
- clangd (C/C++)
- pyright (Python)
- bash-language-server
- vim-language-server
- docker-language-server
- typescript-language-server

### Zshプラグイン
- zsh-autosuggestions (コマンド補完候補)
- zsh-syntax-highlighting (構文ハイライト)
- zsh-you-should-use (エイリアス提案)
- fzf-tab (fuzzy finder統合)
- forgit (gitのインタラクティブ操作)
- zsh-completions (追加の補完定義)

## 📦 前提条件

### ホストシステム要件
- Docker Engine 20.10+
- Docker Compose v2+
- Make
- Git

### 必須ディレクトリ・ファイル
```bash
/etc/systemd/system/docker.service.d/override.conf  # Docker設定
/var/run/docker.sock                                # Dockerソケット
~/.ssh/                                              # SSH鍵（コンテナにマウント）
```

## 🚀 クイックスタート

### 1. リポジトリのクローン
```bash
git clone <このリポジトリのURL>
cd mydev-container
git submodule update --init --recursive
```

### 2. 環境変数の設定
Makefileが自動的に`.env`を生成しますが、必要に応じて編集してください。

```bash
# .envを自動生成
make prepare

# 内容を確認・編集
vim .env
```

### 3. コンテナの起動
```bash
make up
# または
docker compose up -d
```

### 4. コンテナに接続
```bash
docker exec -it main zsh
```

## 🔧 環境の詳細

### ディレクトリ構成
```
.
├── Dockerfile              # コンテナイメージ定義
├── compose.yml            # Docker Compose設定
├── entrypoint.sh          # コンテナ起動時の初期化スクリプト
├── Makefile               # ビルド自動化
├── .env                   # 環境変数（自動生成）
└── config/                # 設定ファイル（ホスト側で管理）
    ├── claude/           # Claude Code設定
    ├── git/              # Git設定
    ├── nvim/             # Neovim設定 (Vim script)
    ├── nvim.lua/         # Neovim設定 (Lua)
    ├── tmux/             # Tmux設定
    └── zsh/              # Zsh設定
```

### マウントポイント
| ホスト | コンテナ | 用途 |
|--------|----------|------|
| `./config` | `/configs` | 設定ファイル |
| `$HOME/data` | `$HOME/data` | プロジェクトデータ |
| `/mnt` | `/mnt` | 追加マウント |
| `/var/run/docker.sock` | `/var/run/docker.sock` | Docker-out-of-Docker |
| `~/.ssh` | `~/.ssh` | SSH鍵 |
| (volume) | `~/.cache` | キャッシュデータ（永続化） |

### UID/GIDマッピング
ホストとコンテナのユーザーIDを一致させることで、ファイルパーミッション問題を回避しています。

```yaml
user: "${UID}:${GID}"
group_add:
  - "${HOST_DOCKER_GID}"  # Dockerグループアクセス
```

### Docker-out-of-Docker (DooD)
コンテナ内からホストのDockerデーモンを使用する構成です。

**メリット:**
- 軽量（Docker in Dockerより）
- ホストのイメージキャッシュを共有

**注意点:**
- コンテナ内で作成したコンテナは、ホスト側に作成されます
- セキュリティリスク：コンテナがホストのDockerを完全制御できます

## 🎨 カスタマイズ

<!-- TODO(human): カスタマイズ方法を記述してください
あなたがよく変更する設定や、追加したツールについて説明してください。
- Neovim
    - 常に最新のものを使用します。
    - プラグインはLazy.nvimを使って管理を行います。
- zsh
    - oh-my-zshでプラグインの管理を行います。
    - zshrcは直接変更を追加せず、プラグインの管理のみを行っています。
    - 自作プラグインを作成し、そこで自分用のエイリアス等をカスタムします。
-->

### 設定ファイルの編集
設定ファイルは`config/`ディレクトリで管理されています。変更後、コンテナを再起動してください。

```bash
# 設定を編集
vim config/zsh/zshrc

# コンテナを再起動
docker restart main
```

### 新しいツールの追加
Dockerfileを編集して、必要なツールを追加できます。

```dockerfile
# Dockerfileに追加
RUN apt install -y <パッケージ名>

# イメージを再ビルド
docker compose build
docker compose up -d
```

## 🐛 トラブルシューティング

### コンテナが起動しない
```bash
# ログを確認
docker logs main

# 環境変数を確認
cat .env

# .envを再生成
make clean-env
make prepare
```

### パーミッションエラー
UID/GIDが正しく設定されているか確認してください。

```bash
# ホストのUID/GIDを確認
id

# .envの内容を確認
grep -E "UID|GID" .env
```

### Docker-in-Dockerが動作しない
```bash
# Dockerグループの確認
docker exec -it main groups

# Docker GIDの確認
grep "^docker" /etc/group
cat .env | grep HOST_DOCKER_GID
```

### 設定ファイルが反映されない
entrypoint.shでシンボリックリンクが正しく作成されているか確認してください。

```bash
# コンテナ内で確認
docker exec -it main ls -la ~/.zshrc
docker exec -it main ls -la ~/.config/nvim
```

## 📝 メンテナンス

### イメージの再ビルド
```bash
# キャッシュを使用せずに再ビルド
docker compose build --no-cache

# コンテナを再作成
docker compose up -d --force-recreate
```

### キャッシュボリュームのクリア
```bash
# コンテナを停止
docker compose down

# キャッシュボリュームを削除
docker volume rm mydev-container_cache-volume

# 再起動
docker compose up -d
```

## 🔒 セキュリティに関する注意

### Docker-out-of-Dockerのリスク
- コンテナ内のプロセスがホストのDockerデーモンに完全アクセス可能
- 本番環境や信頼できないコードの実行には不適切
- 開発環境専用として使用してください

### ネットワークモード: host
```yaml
network_mode: host
```
- コンテナがホストのネットワークスタックを直接使用
- ポートの分離がありません
- 必要に応じて、ポートマッピングに変更を検討してください

## 📚 参考資料

- [Docker公式ドキュメント](https://docs.docker.com/)
- [Neovim公式サイト](https://neovim.io/)
- [Oh My Zsh](https://ohmyz.sh/)

---

## 改善履歴

| 日付 | 変更内容 | 理由 |
|------|----------|------|
| 2025-12-25 | 初版作成 | ドキュメント化開始 |
| 2025-12-25 | Docker環境の最適化（ステップA・B-1） | イメージサイズ削減（7.2GB→7.18GB）、ビルド効率向上 |
| 2025-12-25 | .dockerignore追加 | ビルドコンテキストの最適化 |
| 2025-12-25 | entrypoint.shのエラーハンドリング強化 | 起動時のエラー検出とログ改善 |
| 2025-12-25 | compose.ymlにセキュリティオプション追加 | no-new-privileges設定で権限昇格を防止 |

### 詳細な改善内容（2025-12-25）

**Dockerfile最適化（ステップA）:**
- `DEBIAN_FRONTEND=noninteractive`を追加
- `apt`コマンドを`apt-get`に統一
- クリーンアップ処理の強化（`autoremove`、`/tmp/*`削除）
- 中間ファイルの削除徹底
- 効果: 100MB削減

**Dockerfile最適化（ステップB-1）:**
- zsh/tmuxの重複インストール削除
- apt-get installを3箇所→1箇所に統合（39パッケージ）
- 複数のRUN命令を統合（ユーザー作成、Node.js、Zshプラグイン、Go tools等）
- Dockerfileの行数削減: 189行→160行（15.3%削減）
- レイヤー数削減: 約15-20レイヤー削減
- 効果: 10MB削減、ビルド時間短縮

**entrypoint.sh改善:**
- Bash Strict Mode導入（`set -euo pipefail`）
- エラーハンドリング関数の追加
- ログ機能の実装
- オプショナルファイルのサポート

**compose.yml改善:**
- `security_opt: no-new-privileges:true`追加
- `entrypoint`をbashに変更（shからの移行）

**合計削減量: 110MB（約1.5%）**

<!-- TODO(human): 今後の改善を実施したら、この表に記録してください -->
