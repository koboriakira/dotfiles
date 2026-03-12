# knowledge-reorganize

`~/git/arika/knowledge/` と `~/.claude/skills/` を棚卸しして再構築する。
手動で呼び出し、不要ファイルの削除・統合・整理を行うためのスキル。

## 手順

### 1. 現状把握

以下をすべて読み込む。

**knowledge ファイル:**
```bash
ls -la ~/git/arika/knowledge/
# 各 .md ファイルを Read で読む
```

**skills ディレクトリ:**
```bash
ls ~/.claude/skills/
# 各 skill の SKILL.md を Read で読む
```

**rules ファイル（存在すれば）:**
```bash
ls ~/.dotfiles/.claude/rules/ 2>/dev/null
ls ~/.claude/rules/ 2>/dev/null
```

### 2. 問題点の洗い出し

以下の観点で分析する:

| 問題 | 判断基準 |
|------|---------|
| **重複** | 同じ情報が複数ファイルに記載されている |
| **統合可能** | 小さすぎるファイルや関連性の高いトピック |
| **陳腐化** | 古くなった情報・使われなくなったスキル |
| **粒度のばらつき** | 1スキルが複数の責務を持っている / 細かく分割しすぎ |
| **命名の不統一** | ファイル名・スキル名の一貫性がない |

### 3. 作業計画を提示する

分析結果をもとに以下の形式で提案する:

```
## 提案内容

### 削除
- knowledge/xxx.md → 理由: ○○

### 統合
- knowledge/aaa.md + knowledge/bbb.md → knowledge/ccc.md
  理由: ○○

### リネーム
- skills/old-name → skills/new-name
  理由: ○○

### 内容修正
- knowledge/yyy.md: セクション「△△」を削除/更新
  理由: ○○
```

**ユーザーの確認を求める。承認されたら次のステップへ進む。**

### 4. 実行

承認された変更を順番に実行する:

1. ファイルの統合: 新ファイルを作成してから旧ファイルを削除
2. ファイルの削除: `Bash` で `rm` を実行
3. スキルのリネーム: ディレクトリごと `mv`
4. `knowledge/README.md` のファイル一覧を最新状態に更新

### 5. 完了報告

実行した変更の一覧と、整理後のファイル構成を報告する。
