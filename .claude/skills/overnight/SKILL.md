---
name: overnight
description: Prepare a comprehensive autonomous task prompt for overnight non-interactive execution. Use when the user is about to sleep and wants to maximize Claude usage during idle hours.
disable-model-invocation: true
allowed-tools: Bash, Read, Grep, Glob, Write, Edit, AskUserQuestion, mcp__github__list_issues, mcp__github__get_issue, mcp__github__search_issues, mcp__github__get_me, mcp__github__list_pull_requests, mcp__github__search_pull_requests
---

# Overnight Task Preparation

就寝前にユーザーと対話しながら、現在のリポジトリを対象に非対話モードで実行可能な自律作業プロンプトを生成する。

**前提**: 現在のディレクトリが対象リポジトリのルートであること。

## 実行フロー

### 1. 現状の把握

現在のリポジトリの状態を収集する:

- `git remote -v` でリポジトリの owner/repo を特定
- `git status` で作業ツリーの状態を確認
- `git log --oneline -10` で最近のコミットを確認
- CLAUDE.md やプロジェクト固有のルールを確認

### 2. イシューの収集と分析

現在のリポジトリのオープンイシューを収集する:

```bash
gh issue list --state open --json number,title,body,labels,assignees,createdAt --limit 20
```

### 3. イシューの実現可能性を評価

各イシューについて以下の観点で**自律作業への適性**を判定する:

| 評価軸 | 高適性 | 低適性 |
|--------|--------|--------|
| スコープ | 明確で限定的 | 曖昧・広範 |
| 依存関係 | 外部サービス不要 | API キー・外部認証が必要 |
| 検証可能性 | テストで確認可能 | 手動確認が必要 |
| リスク | 新規追加・リファクタ | データ削除・破壊的変更 |
| 情報の充足 | イシューだけで着手可能 | ユーザーへの追加質問が必要 |

評価結果を以下の3段階で分類する:
- **A**: 高い確度で自律完了可能
- **B**: 概ね自律可能だが一部リスクあり
- **C**: 自律作業に不向き（スキップ推奨）

### 4. 候補の提示と選択

ユーザーに以下の形式で候補を提示する:

```
## 候補イシュー

| # | イシュー | 評価 | 推定規模 | 概要 |
|---|---------|------|---------|------|
| 1 | #123 タイトル | A | 小 | 説明 |
| 2 | #456 タイトル | B | 中 | 説明 |

どのイシューに取り組みますか？（番号で選択、複数可）
```

ユーザーが選択したイシューについて、必要なら追加のコンテキストを収集する:
- 関連するコードの構造（ディレクトリ・主要ファイル）
- 既存のテスト構成
- CI/CD の設定
- CLAUDE.md やプロジェクト固有のルール

### 5. プロンプトの生成

選択されたイシューに対して、以下の構造でプロンプトを生成する。
テンプレートの詳細は [prompt-template.md](prompt-template.md) を参照。

**生成のポイント:**
- 全てのコンテキストを自己完結させる（非対話なのでユーザーに質問できない）
- 各イシューの作業を独立したセクションとして記述する
- 安全側に倒す制約を明示する（force push 禁止、main 直接変更禁止等）
- 作業ブランチの命名規則を指定する
- コミットメッセージの規約を含める
- テスト実行と成功確認を必須にする

### 6. 実行時刻の確認

ユーザーに開始時刻を確認する:

```
何時から実行を開始しますか？
1. 今すぐ
2. 時刻を指定（例: 03:00）
```

### 7. 出力と実行方法の案内

生成したプロンプトを以下に保存する:
```
~/.claude/overnight/YYYY-MM-DD_overnight-task.md
```

**即時実行の場合:**
```bash
cd <target-repo-path> && claude -p "$(cat ~/.claude/overnight/YYYY-MM-DD_overnight-task.md)" --output-format text --allowedTools 'Bash(git:*),Bash(npm:*),Bash(cargo:*),Bash(python:*),Bash(go:*),Read,Write,Edit,Glob,Grep,mcp__github__create_pull_request,mcp__github__create_branch'
```

**時刻指定の場合:**

指定時刻まで `sleep` で待機してから実行するワンライナーを生成する。
実行スクリプトを `~/.claude/overnight/YYYY-MM-DD_run.sh` に保存し、`nohup` で起動する。

スクリプトの内容:
```bash
#!/bin/bash
# 指定時刻まで待機して claude を実行する
TARGET="HH:MM"
NOW=$(date +%s)
TARGET_TS=$(date -j -f "%Y-%m-%d %H:%M" "$(date +%Y-%m-%d) $TARGET" +%s)
# 指定時刻が過去なら翌日として扱う
if [ "$TARGET_TS" -le "$NOW" ]; then
  TARGET_TS=$((TARGET_TS + 86400))
fi
DELAY=$((TARGET_TS - NOW))
echo "$(date): ${DELAY}秒後（${TARGET}）に実行開始します"
sleep $DELAY
echo "$(date): 実行開始"
unset CLAUDECODE
cd <target-repo-path> && claude -p "$(cat ~/.claude/overnight/YYYY-MM-DD_overnight-task.md)" --output-format text --allowedTools 'Bash(git:*),Bash(npm:*),Bash(cargo:*),Bash(python:*),Bash(go:*),Read,Write,Edit,Glob,Grep,mcp__github__create_pull_request,mcp__github__create_branch'
```

ユーザーへの提示コマンド:
```bash
nohup bash ~/.claude/overnight/YYYY-MM-DD_run.sh > ~/.claude/overnight/YYYY-MM-DD_output.log 2>&1 &
```

これにより、ターミナルを閉じても指定時刻に実行が開始される。

## 注意事項

- プロンプトには機密情報（トークン、パスワード等）を含めない
- 破壊的操作（データ削除、force push 等）は明示的に禁止する
- 生成されたプロンプトは実行前にユーザーが確認できるよう、ファイルとして保存する
- `--allowedTools` で許可するツールは最小限にする
