---
name: create-skill
description: Claude Code のスキルを作成するメタスキル。スキル作成、スラッシュコマンド作成、SKILL.md の生成を依頼されたときに使用する。
disable-model-invocation: true
argument-hint: "[スキル名] [概要]"
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

# スキル作成メタスキル

Claude Code の Agent Skills 仕様に準拠したスキルを作成する。

## 作成フロー

### 1. 要件の収集

以下をユーザから確認する。不足している場合は `AskUserQuestion` で質問する。

**必須:**
- スキル名（kebab-case、英数字とハイフンのみ、最大64文字）
- スキルの目的と概要

**推奨:**
- 呼び出し方式（ユーザ手動のみ / Claude自動判断 / Claudeのみ）
- 実行コンテキスト（インライン / サブエージェント fork）
- 許可するツール（allowed-tools）
- 引数の有無と形式

**任意:**
- サポートファイルの要否（テンプレート、スクリプト、リファレンス等）
- 動的コンテキスト注入（!`command`）の要否
- 使用するモデル
- フック定義

### 2. スキルタイプの判定

ユーザの要件から、以下のどちらに該当するか判断する:

| タイプ | 説明 | 典型的な設定 |
|--------|------|-------------|
| **リファレンス型** | 知識・規約・パターンを追加する | デフォルト設定でインライン実行 |
| **タスク型** | 具体的なアクションを実行する | `disable-model-invocation: true` + 必要に応じて `context: fork` |

### 3. 保存先の決定

| 場所 | パス | 用途 |
|------|------|------|
| 個人用 | `~/.claude/skills/<name>/SKILL.md` | 全プロジェクトで使用 |
| プロジェクト | `.claude/skills/<name>/SKILL.md` | このプロジェクトのみ |

ユーザに確認して適切な場所を選択する。

### 4. ファイル生成

1. スキルディレクトリを作成する
2. `SKILL.md` を生成する（フロントマター + マークダウン本文）
3. 必要に応じてサポートファイルを作成する

フロントマターとテンプレートの詳細は [reference.md](reference.md) を参照。
スキルの具体例は [examples/](examples/) を参照。

### 5. 生成内容の確認

作成後、以下を提示する:

- 作成したファイルの一覧
- テスト方法（スキルの呼び出し方式に応じた確認手順）
- 必要に応じた改善提案

## フロントマター設計ガイドライン

### description の書き方

- Claude が自動判断で呼び出せるよう、**いつ使うか**を明確に書く
- ユーザが自然に使う表現やキーワードを含める
- 英語で書く（Claude の自動判断精度が高い）

良い例:
```
description: Generate unit tests for functions. Use when writing tests, adding test coverage, or when asked to test code.
```

悪い例:
```
description: テスト関連のスキル
```

### allowed-tools の設計

- 最小権限の原則に従う
- 読み取り専用スキルには `Read, Grep, Glob` のみ
- 副作用があるスキルは必要なツールだけを許可する
- Bash を許可する場合はパターンで絞る: `Bash(npm:*)`、`Bash(git:*)`

### context: fork の使いどころ

以下に該当する場合は `context: fork` を設定する:
- 長時間の調査タスク
- メインの会話コンテキストを消費したくない場合
- 独立した処理として実行したい場合

`agent` フィールドで実行エージェントを指定可能:
- `Explore` - コードベース調査（読み取り専用）
- `Plan` - 設計・計画（読み取り専用）
- `general-purpose` - 汎用（デフォルト、全ツール使用可）

## 制約

- SKILL.md は 500 行以下に保つ。詳細はサポートファイルに分離する
- セキュリティに配慮する（認証情報の扱い、外部リクエストの制限等）
- フロントマターの `version` フィールドは公式仕様に存在しないため使用しない
- 日本語で記述する（description は英語推奨）
