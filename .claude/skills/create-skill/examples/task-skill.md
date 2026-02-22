# タスク型スキルの例

## 例1: コミットスキル

```yaml
---
name: commit
description: Create a conventional commit with proper message format
disable-model-invocation: true
allowed-tools: Bash(git:*)
---

# コミット作成

## 手順

1. `git diff --cached` でステージされた変更を確認
2. 変更内容を分析し、Conventional Commit 形式でメッセージを作成
3. コミットを実行

## メッセージ形式

\```
<type>(<scope>): <subject>

<body>

<footer>
\```

type: feat, fix, refactor, chore, docs, test, ci
```

## 例2: PR レビュースキル

```yaml
---
name: review-pr
description: Review a pull request for code quality, security, and best practices
disable-model-invocation: true
argument-hint: "[PR番号またはURL]"
allowed-tools: Bash(gh:*), Read, Grep, Glob
---

# PR レビュー

## PR 情報の取得

$ARGUMENTS の PR を取得する:

1. `gh pr diff $ARGUMENTS` で差分を取得
2. `gh pr view $ARGUMENTS` で PR の概要を確認

## レビュー観点

- コードの正確性
- セキュリティ（OWASP Top 10）
- パフォーマンス
- テストカバレッジ
- 命名規約の遵守

## 出力形式

各ファイルについて:
- 問題の深刻度（Critical / Warning / Info）
- 該当箇所（ファイル名:行番号）
- 問題の説明と改善案
```

## 例3: デプロイスキル

```yaml
---
name: deploy
description: Deploy the application to production
disable-model-invocation: true
argument-hint: "[staging|production]"
allowed-tools: Bash(npm:*, docker:*, git:*)
---

# デプロイ

対象環境: $ARGUMENTS

## 手順

1. テストスイートを実行
2. ビルド
3. デプロイターゲットにプッシュ
4. デプロイ後の動作確認

## 注意事項

- production デプロイ前に staging での検証を確認する
- ロールバック手順を把握しておく
```
