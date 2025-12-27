# Docker開発環境

Neovimを中心とした統合開発環境をDocker化したプロジェクトです。主に組込みLinuxのC/Bash/Python開発を行いますが、Rust、Go、TypeScriptなど他の言語にも対応しています。

**特徴:**
- 🎯 **ホスト非依存**: ホストOSを汚さず、完全に再現可能な開発環境
- ⚡ **モダンツール**: 最新のNeovim、LSP、Rustツール群を統合
- 🔧 **カスタマイズ可能**: 設定ファイルはホスト側で管理、即座に反映
- 🐳 **Docker-out-of-Docker**: コンテナ内からホストのDockerを使用可能
- 🎨 **快適なターミナル環境**: Zsh + Tmux + 豊富なプラグイン

## 📋 目次

- [機能](#機能)
- [前提条件](#前提条件)
- [クイックスタート](#クイックスタート)
- [環境の詳細](#環境の詳細)
- [各ツールの使い方ガイド](#各ツールの使い方ガイド)
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

## 📚 各ツールの使い方ガイド

### Neovim
最新版のNeovimをソースビルドで導入。LSP、補完、ファイルツリーなど、IDE並みの機能を提供します。

```bash
# Neovimを起動
nvim

# プラグインマネージャー（Lazy.nvim）を開く
# Neovim内で
:Lazy

# LSPの状態確認
:LspInfo

# ファイルツリー（通常は設定でマッピング済み）
# 例: <leader>e でトグル
```

**よく使うコマンド:**
- `:Mason` - LSPサーバーやツールのインストール管理
- `:checkhealth` - Neovimの健全性チェック
- `:Telescope find_files` - ファジーファインダーでファイル検索

### Tmux
ターミナルマルチプレクサ。複数のウィンドウやペインを管理できます。

```bash
# Tmuxセッション開始
tmux

# 新しいセッションを名前付きで開始
tmux new -s セッション名

# セッションにアタッチ
tmux attach -t セッション名

# セッション一覧
tmux ls
```

**基本的なキーバインド（デフォルト Prefix: Ctrl+b）:**
- `Prefix + c` - 新しいウィンドウ作成
- `Prefix + %` - ペインを縦分割
- `Prefix + "` - ペインを横分割
- `Prefix + 矢印キー` - ペイン間の移動
- `Prefix + d` - デタッチ（セッション保持）

### Lazygit
Gitの操作を視覚的に行える強力なTUIツールです。

```bash
# Lazygitを起動（gitリポジトリ内で）
lazygit

# または lg エイリアスが設定されている場合
lg
```

**基本操作:**
- `j/k` - 上下移動
- `Space` - ステージング/アンステージング
- `c` - コミット
- `P` - プッシュ
- `p` - プル
- `?` - ヘルプ表示

### fzf（Fuzzy Finder）
あいまい検索で素早くファイルやコマンドを見つけられます。

```bash
# ファイル検索（Ctrl+T）
# コマンドラインで Ctrl+T を押す

# コマンド履歴検索（Ctrl+R）
# コマンドラインで Ctrl+R を押す

# ディレクトリ移動（Alt+C）
# コマンドラインで Alt+C を押す

# 手動でfzfを使用
find . -type f | fzf
```

### Rustツール群

#### ripgrep (rg)
超高速なgrepツール。コードベースの検索に最適です。

```bash
# パターン検索
rg "検索パターン"

# ファイルタイプを指定
rg "検索パターン" -t rust

# 隠しファイルも含めて検索
rg "検索パターン" --hidden

# コンテキスト表示（前後3行）
rg "検索パターン" -C 3
```

#### fd
findの代替ツール。シンプルで高速なファイル検索。

```bash
# ファイル名検索
fd ファイル名

# 拡張子で検索
fd -e rs

# 隠しファイルも含める
fd -H ファイル名

# ディレクトリのみ検索
fd -t d ディレクトリ名
```

#### eza
lsの代替ツール。カラフルで見やすい出力。

```bash
# 通常のリスト表示（llエイリアスが設定されている場合）
ll

# ツリー表示
eza --tree

# Gitステータスも表示
eza --git --long
```

#### bat
catの代替ツール。シンタックスハイライト付き。

```bash
# ファイルの内容を表示
bat ファイル名

# 行番号なしで表示
bat -p ファイル名

# 複数ファイルを連結表示
bat file1 file2
```

#### zoxide
cd の賢い代替ツール。頻繁に訪れるディレクトリを記憶します。

```bash
# 初回は通常のcdを使用（学習）
cd /path/to/project

# 以降はzoxide（zコマンド）で素早く移動
z project

# インタラクティブ選択
zi

# 学習したディレクトリ一覧
zoxide query -l
```

### Claude Code
Claude AIを使ったコーディング支援ツール（プライベート利用）。

```bash
# Claude Codeを起動（プロジェクトディレクトリで）
claude

# 特定のプロンプトで起動
claude "コードレビューをお願いします"

# 設定ファイルの確認
cat ~/.claude/CLAUDE.md
```

## 🎨 カスタマイズ

### Neovim設定
Neovimは常に最新版をソースからビルドしています。プラグイン管理はLazy.nvimを使用。

```bash
# Neovim設定の編集
vim config/nvim.lua/init.lua

# コンテナを再起動して反映
docker restart main
```

**Lazy.nvim**でプラグインを追加する場合は、`config/nvim.lua/lua/plugins/`にファイルを追加してください。

### Zsh設定
Oh My Zshでプラグインを管理しています。`zshrc`は直接変更せず、自作プラグイン（`myconfig`）でエイリアスやカスタム設定を追加する方針です。

```bash
# 自作プラグインで設定を追加
vim config/zsh/myconfig/myconfig.plugin.zsh

# Oh My Zshプラグインを追加する場合
# 1. Dockerfileのohmyzshセクションを編集
vim Dockerfile

# 2. イメージを再ビルド
docker compose build
```

### 新しいツールの追加
開発ツールを追加する場合、Dockerfileの適切な箇所に追加してください。

```dockerfile
# システムパッケージの場合
RUN apt-get update && apt-get install -y \
    既存のパッケージ \
    新しいパッケージ

# Cargoツールの場合
RUN cargo install 新しいツール
```

変更後は`docker compose build`でイメージを再ビルドしてください。

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

#### 症状: `docker compose up`でエラーが出る
```bash
# ログを確認
docker logs main

# 環境変数を確認
cat .env

# .envを再生成
make clean-env
make prepare

# 強制的に再作成
docker compose down
docker compose up -d --force-recreate
```

#### 症状: entrypoint.shでエラーが出る
entrypoint.shのログを確認してください。よくある原因:
- 設定ファイルのパスが間違っている
- マウントポイントが正しくない

```bash
# エラーログを詳しく確認
docker logs main 2>&1 | grep ERROR

# entrypoint.shを手動実行してデバッグ
docker exec -it main bash /entrypoint.sh
```

### パーミッションエラー

#### 症状: ファイルの作成・編集ができない
UID/GIDが正しく設定されているか確認してください。

```bash
# ホストのUID/GIDを確認
id

# .envの内容を確認
grep -E "UID|GID" .env

# コンテナ内のユーザーIDを確認
docker exec -it main id

# 不一致の場合は.envを修正して再起動
vim .env
docker compose down
docker compose up -d
```

#### 症状: マウントしたディレクトリが読み取り専用
compose.ymlのマウント設定を確認してください。

```bash
# read_only: trueになっていないか確認
grep -A 5 "source.*DATA_DIR" compose.yml

# マウントポイントの確認
docker exec -it main mount | grep data
```

### Docker-out-of-Dockerが動作しない

#### 症状: `docker: permission denied`エラー
```bash
# Dockerグループの確認
docker exec -it main groups

# Docker GIDの確認（ホスト側）
grep "^docker" /etc/group
cat .env | grep HOST_DOCKER_GID

# GIDが不一致の場合は.envを修正
vim .env
docker compose down
docker compose up -d
```

#### 症状: Dockerソケットが見つからない
```bash
# Dockerソケットの存在確認（ホスト側）
ls -l /var/run/docker.sock

# マウントされているか確認（コンテナ側）
docker exec -it main ls -l /var/run/docker.sock

# Dockerデーモンが起動しているか確認
systemctl status docker
```

### 設定ファイルが反映されない

#### 症状: Zshの設定変更が反映されない
entrypoint.shでシンボリックリンクが正しく作成されているか確認してください。

```bash
# シンボリックリンクの確認
docker exec -it main ls -la ~/.zshrc
docker exec -it main readlink ~/.zshrc

# 正しくリンクされていない場合は再起動
docker restart main

# それでも反映されない場合はシェルを再起動
docker exec -it main zsh
```

#### 症状: Neovim設定が読み込まれない
```bash
# シンボリックリンクの確認
docker exec -it main ls -la ~/.config/nvim

# Neovim内で設定ファイルのパスを確認
docker exec -it main nvim -c ":echo stdpath('config')" -c ":q"

# Neovimのヘルスチェック
docker exec -it main nvim -c ":checkhealth" -c ":q"
```

### ビルドエラー

#### 症状: `apt-get install`が失敗する
ネットワークやプロキシ設定を確認してください。

```bash
# プロキシ設定の確認
cat .env | grep -E "HTTP_PROXY|HTTPS_PROXY"

# キャッシュをクリアして再ビルド
docker compose build --no-cache

# ビルドログを詳細に確認
docker compose build --progress=plain
```

#### 症状: Neovimのビルドが失敗する
依存パッケージが不足している可能性があります。

```bash
# ビルドログを確認
docker compose build 2>&1 | grep -A 10 "neovim"

# キャッシュなしで再ビルド
docker compose build --no-cache

# Dockerfileの該当箇所を確認
vim Dockerfile
# Neovimビルドに必要なパッケージが全てインストールされているか確認
```

### ネットワーク関連の問題

#### 症状: コンテナ内からインターネットに接続できない
```bash
# DNS設定の確認
docker exec -it main cat /etc/resolv.conf

# 疎通確認
docker exec -it main ping -c 3 8.8.8.8
docker exec -it main curl -I https://google.com

# プロキシ設定の確認（必要な場合）
docker exec -it main env | grep -i proxy
```

#### 症状: ホストのサービスに接続できない
`network_mode: host`を使用しているため、基本的にはホストと同じネットワークです。

```bash
# ホスト側でサービスが起動しているか確認
ss -tlnp | grep ポート番号

# コンテナ内から接続確認
docker exec -it main curl http://localhost:ポート番号
```

### Neovimプラグインのエラー

#### 症状: Lazy.nvimでプラグインがインストールできない
```bash
# コンテナ内でNeovimを起動
docker exec -it main nvim

# Neovim内でLazy.nvimのログを確認
:Lazy log

# プラグインを手動でインストール
:Lazy install

# ヘルスチェックでエラーを確認
:checkhealth lazy
```

#### 症状: LSPが動作しない
```bash
# Masonでインストール状況を確認
docker exec -it main nvim -c ":Mason"

# LSP情報を確認
docker exec -it main nvim ファイル名 -c ":LspInfo"

# ヘルスチェック
docker exec -it main nvim -c ":checkhealth lsp"
```

### ログが肥大化している

#### 症状: Dockerログが大きくなりすぎた
compose.ymlのlogging設定で制限していますが、手動でクリアすることも可能です。

```bash
# ログサイズを確認
docker inspect --format='{{.LogPath}}' main | xargs ls -lh

# ログをクリア（コンテナを一時停止）
docker compose down
sudo truncate -s 0 $(docker inspect --format='{{.LogPath}}' main)
docker compose up -d

# または完全に再作成
docker compose down
docker compose up -d --force-recreate
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
| 2025-12-26 | Dockerfileのレイヤー順序最適化（ステップB-2） | 再ビルド時のキャッシュ効率向上 |
| 2025-12-28 | compose.ymlにログ設定追加 | ログローテーション（max-size: 10m, max-file: 3）でディスク容量管理 |
| 2025-12-28 | README.mdドキュメント強化 | 各ツールの使い方ガイド追加、トラブルシューティング充実 |

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

### 詳細な改善内容（2025-12-26）

**Dockerfile最適化（ステップB-2）:**
- レイヤー順序を変更頻度別に最適化
- Dockerインストール: 後半→前半に移動
- Neovimビルド: 中盤→前半に移動
- ohmyzshプラグイン: 後半に配置（変更頻度が高いため）
- 効果: 再ビルド時のキャッシュヒット率向上
  - 例: ohmyzshプラグイン追加時、Neovimビルド（5-10分）をスキップ可能

**新しいレイヤー順序:**
1. システム基盤（ベースイメージ、ユーザー作成、パッケージインストール）
2. 言語環境（npm、Node.js、Docker）
3. ビルド処理（Neovimソースビルド）
4. ユーザー空間ツール（Claude、Go、Rust、Cargo）
5. プラグイン（ohmyzsh）- 変更頻度が最も高い

<!-- TODO(human): 今後の改善を実施したら、この表に記録してください -->
