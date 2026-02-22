# リファレンス型スキルの例

## 例1: API 設計規約

```yaml
---
name: api-conventions
description: REST API design patterns and conventions for this codebase. Use when writing API endpoints, designing routes, or reviewing API code.
---

# API 設計規約

## エンドポイント命名

- リソース名は複数形: `/users`, `/posts`
- ネストは2階層まで: `/users/:id/posts`
- アクション名はなるべく避ける（REST で表現）

## レスポンス形式

成功時:
\```json
{
  "data": { ... },
  "meta": { "page": 1, "total": 100 }
}
\```

エラー時:
\```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "...",
    "details": [...]
  }
}
\```

## ステータスコード

- 200: 成功（GET, PUT, PATCH）
- 201: 作成成功（POST）
- 204: 削除成功（DELETE）
- 400: バリデーションエラー
- 401: 認証エラー
- 403: 権限エラー
- 404: リソース未発見
- 500: サーバーエラー
```

## 例2: コーディングスタイル

```yaml
---
name: coding-style
description: TypeScript coding style guide. Use when writing or reviewing TypeScript code.
user-invocable: false
---

# TypeScript コーディングスタイル

- 型の明示: 関数の引数と戻り値には型を付ける
- any 禁止: unknown を使う
- enum より union type を優先
- interface より type を優先（拡張が必要な場合を除く）
- エラー処理は Result 型パターンを使う
```
