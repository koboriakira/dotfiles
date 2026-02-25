# セッション記録（Obsidian）

セッション中のやりとりを要約し、Obsidian Vault にノートとして保存・更新する。

## Vault パス

```
$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/my-vault
```

## 保存先ディレクトリとファイル名

| 種類 | 保存先 | 説明 |
|------|--------|------|
| Chat | `Claude/Chat/` | コードの変更を伴わない質疑応答・相談・雑談 |
| Code | `Claude/Code/{organization}/{repository}/` | 特定リポジトリに対するコード変更を伴う作業 |

- ファイル名: `YYYY-MM-DD_トピック.md`（例: `2026-02-23_音声読み上げ仕様変更.md`）
- organization と repository は、作業対象の Git リモートURLから判定する
- 同一セッションで同じファイルに追記・更新していく

## ノートのフォーマット

```markdown
---
date: YYYY-MM-DD
type: chat | code
repository: organization/repository  # code の場合のみ
---

# トピック名

## 概要
（セッション全体の要約を2〜3文で）

## やりとりの詳細

### マイルストーン1のタイトル
- 何をしたか
- 決定事項や結論
- 注意点や残課題があれば
```

## 注意事項

- ノートは要約であり逐語録ではない。重要な決定・変更・結論を中心に記録する
- 既存のノートがある場合は上書きせず、マイルストーンのセクションを追記・更新する
- ディレクトリが存在しない場合は自動作成する
