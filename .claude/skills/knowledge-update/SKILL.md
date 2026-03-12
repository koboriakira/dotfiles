# knowledge-update

直近のObsidianセッションノートを読み込み、私の個人知識ベース（`~/git/arika/knowledge/`）を自律的に更新する。

## 手順

### 1. 直近7日分のセッションノートを収集

以下のディレクトリを対象に、直近7日以内のファイルを列挙して読み込む。

```
~/Library/Mobile Documents/iCloud~md~obsidian/Documents/my-vault/Claude/Chat/
~/Library/Mobile Documents/iCloud~md~obsidian/Documents/my-vault/Claude/Code/
```

`find` コマンドで7日以内のファイルを取得:
```bash
find "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/my-vault/Claude" \
  -name "*.md" -mtime -7 | sort
```

### 2. 既存の knowledge/ ファイルを読み込む

`~/git/arika/knowledge/` 以下の全ファイルを読み込み、現在の知識ベースを把握する。

### 3. 新しい知識を抽出・分類する

セッションノートから以下の観点で情報を抽出する:

| カテゴリ | 例 |
|----------|-----|
| 食べ物・飲み物の好み | 日本酒の銘柄、好きな料理、苦手な食材 |
| 趣味・興味 | スポーツ、音楽、ゲーム、読書 |
| 人間関係・コミュニティ | 友人、チームメンバー、よく会う場所 |
| ワークフロー・習慣 | 作業スタイル、ルーティン、使うツール |
| 考え方・価値観 | 判断基準、こだわり、好みのアプローチ |
| プロジェクト・進捗 | 新しく始めたこと、完了したこと |

### 4. ファイルを更新・作成する

- **既存ファイルへの追記**: 関連トピックがあれば追記する（重複しないよう確認）
- **新規ファイル作成**: 新しいトピックは `knowledge/{topic}.md` として作成
  - ファイル名は英語のスネークケース（例: `sake.md`, `food_preferences.md`）
- **README.md 更新**: ファイル一覧を最新状態に保つ

### 5. 完了報告

更新・作成したファイルの一覧と変更内容を簡潔に報告する。
変更がなかった場合も「変更なし」と報告する。
