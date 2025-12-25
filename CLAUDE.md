# Docker開発環境プロジェクト - Claude Code指示

このプロジェクトはDocker化された開発環境です。以下のルールに従ってください。

## プロジェクト概要

**目的:** Neovimを中心とした統合開発環境をDockerで構築
**主な用途:** 組込みLinux開発（C/Bash/Python）+ モダン言語開発
**方針:** ホストOSを汚さず、再現可能で最新ツールを使った開発環境

## 重要な原則

### 1. 現在の作業環境に配慮

⚠️ **最重要**: このプロジェクトのDocker環境は、現在の作業環境そのものです。

- **テスト時の注意**: `docker compose up`や`docker restart main`は現在の環境を停止させます
- **テスト方法**: `docker compose build`でビルドのみ行い、実際の起動テストはユーザーの判断に委ねる
- **代替環境**: 別名イメージ（`main-test`等）を使った並行テストを推奨

### 2. Docker関連ファイルの扱い

**対象ファイル:**
- `Dockerfile` - イメージ定義
- `compose.yml` - コンテナ設定
- `entrypoint.sh` - 起動スクリプト
- `.dockerignore` - ビルドコンテキスト除外
- `Makefile` - ビルド自動化
- `.env` - 環境変数（自動生成、直接編集禁止）

**変更時のルール:**
1. 段階的に変更（一度に大きく変えない）
2. 変更理由を明確に
3. README.mdの改善履歴を更新
4. テストビルドで確認（`docker compose build`）

### 3. 最適化の方針

**優先順位:**
1. **安全性** - 既存の動作を壊さない
2. **保守性** - コードの可読性、メンテナンス性
3. **効率性** - イメージサイズ、ビルド時間

**段階的アプローチ:**
- 小規模な改善 → テスト → 大規模な改善
- 問題発生時の原因特定を容易にする

## 禁止事項

❌ **絶対にやってはいけないこと:**

1. `.env`ファイルの直接編集（Makefileで自動生成）
2. テスト時に現在の環境を停止させる操作（`docker compose up -d`等）
3. 動作確認なしの大規模リファクタリング
4. セキュリティを低下させる変更

## 推奨事項

✅ **推奨される作業パターン:**

### Dockerfile変更時
```bash
# 1. ビルドテスト
docker compose build

# 2. イメージサイズ確認
docker images main

# 3. (ユーザー判断) 実環境テスト
# docker compose up -d --force-recreate
```

### 設定ファイル変更時（config/）
```bash
# 設定はマウントされているため、コンテナ再起動で反映
docker restart main
```

### entrypoint.sh変更時
```bash
# バインドマウントのため、コンテナ再起動で反映
docker restart main
```

## ファイル構造の理解

```
.
├── Dockerfile          # イメージビルド定義（変更頻度: 低）
├── compose.yml        # コンテナ実行設定（変更頻度: 低）
├── entrypoint.sh      # 起動時処理（変更頻度: 中）
├── Makefile           # 自動化スクリプト（変更頻度: 低）
├── .env               # 環境変数（自動生成、編集禁止）
├── .dockerignore      # ビルド除外ファイル
├── README.md          # ドキュメント
├── CLAUDE.md          # このファイル
└── config/            # 設定ファイル（変更頻度: 高）
    ├── claude/
    ├── git/
    ├── nvim/
    ├── nvim.lua/
    ├── tmux/
    └── zsh/
```

## Docker最適化のベストプラクティス

### Dockerfileレイヤー戦略

**変更頻度の低い順に配置:**
1. ベースイメージ、環境変数、ユーザー作成
2. apt-get install（システムパッケージ）
3. 言語環境構築（Node.js、Go、Rust）
4. ユーザー空間ツール
5. 設定ファイル（頻繁に変更される場合はマウント推奨）

**RUN命令の統合:**
- 関連する処理は1つのRUN命令にまとめる
- `&&`でコマンドを連結
- 中間ファイルは同じRUN内で削除

**キャッシュ効率化:**
- `apt-get update && apt-get install`は同じRUNで
- 不要なファイルは各RUNの最後で削除
- 最終的に`apt-get clean`と`rm -rf /var/lib/apt/lists/*`

### compose.yml設計

**セキュリティ設定:**
- `security_opt: no-new-privileges:true` - 権限昇格防止
- `read_only: true` - 読み取り専用マウント（設定ファイル等）

**開発環境 vs 本番環境:**
- 開発: 柔軟性優先（書き込み可能マウント）
- 本番: 安全性優先（read_only、リソース制限、ヘルスチェック）

## トラブルシューティング

### ビルドエラー
```bash
# キャッシュをクリアして再ビルド
docker compose build --no-cache

# 環境変数を確認
cat .env

# .envを再生成
make clean-env
make prepare
```

### コンテナ起動エラー
```bash
# ログ確認
docker logs main

# entrypoint.shの実行確認
docker exec -it main bash -c "cat /entrypoint.sh"
```

## 改善提案時のテンプレート

新しい改善を提案する際は、以下の情報を含めてください：

```markdown
## 改善提案: [改善内容の要約]

**目的:** [なぜこの改善が必要か]

**変更ファイル:**
- [ ] Dockerfile
- [ ] compose.yml
- [ ] entrypoint.sh
- [ ] その他: ___

**期待される効果:**
- イメージサイズ: ___
- ビルド時間: ___
- メンテナンス性: ___

**リスク評価:**
- [ ] 低（既存機能に影響なし）
- [ ] 中（一部機能に影響の可能性）
- [ ] 高（大規模な変更）

**テスト方法:**
1. [ステップ1]
2. [ステップ2]
```

---

## 参考: 過去の最適化実績

- **2025-12-25**: イメージサイズ削減 7.2GB → 7.18GB（110MB削減）
  - ステップA: クリーンアップ強化（100MB）
  - ステップB-1: RUN命令統合（10MB）
  - Dockerfile: 189行 → 160行（15.3%削減）

---

**最終更新:** 2025-12-25
