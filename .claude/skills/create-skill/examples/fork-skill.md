# サブエージェント（fork）型スキルの例

## 例1: コードベース調査

```yaml
---
name: deep-research
description: Research a topic thoroughly across the codebase
context: fork
agent: Explore
---

# コードベース調査

$ARGUMENTS について徹底的に調査する。

## 調査手順

1. Glob と Grep で関連ファイルを特定
2. コードを読み込んで分析
3. 依存関係とデータフローを追跡
4. 発見事項をファイルパス付きでまとめる

## 出力形式

- 関連ファイルの一覧（パスと役割）
- アーキテクチャの概要
- 主要な処理フロー
- 注意点や技術的負債
```

## 例2: セキュリティ監査

```yaml
---
name: security-audit
description: Audit codebase for security vulnerabilities
context: fork
agent: Explore
allowed-tools: Read, Grep, Glob
---

# セキュリティ監査

## チェック項目

1. **認証・認可**: 未保護のエンドポイント、権限チェックの漏れ
2. **インジェクション**: SQL, XSS, コマンドインジェクション
3. **データ漏洩**: ログへの機密情報出力、エラーメッセージの情報漏洩
4. **依存関係**: 既知の脆弱性を持つパッケージ
5. **設定**: ハードコードされた秘密情報、デバッグモード

## 出力形式

各発見事項について:
- 深刻度: Critical / High / Medium / Low
- 該当箇所: ファイルパスと行番号
- 問題の説明
- 修正案
```

## 例3: 動的コンテキスト注入を使った PR サマリー

```yaml
---
name: pr-summary
description: Summarize changes in the current pull request
context: fork
agent: Explore
allowed-tools: Bash(gh:*)
---

## PR コンテキスト

- 差分: !`gh pr diff`
- コメント: !`gh pr view --comments`
- 変更ファイル: !`gh pr diff --name-only`

## タスク

この PR の変更内容を要約してください。

- 変更の目的
- 主要な変更点（ファイルごと）
- 影響範囲
- レビュー時の注意点
```
