# エージェントチーム プロンプト例

## 1. 並行コードレビュー

異なる観点で同時にレビューし、見落としを防ぐ。

```
Create an agent team to review PR #142. Spawn three reviewers:
- One focused on security implications
- One checking performance impact
- One validating test coverage
Have them each review and report findings. Synthesize into a single review.
```

## 2. 競合仮説デバッグ

原因不明のバグに対し、複数の仮説を並行で検証する。

```
Users report the app crashes after login on iOS.
Spawn 4 agent teammates to investigate different hypotheses:
- Memory leak in the auth module
- Race condition in the session manager
- API timeout handling issue
- Token refresh logic bug

Have them talk to each other to try to disprove each other's theories.
Update findings with whatever consensus emerges.
```

## 3. フルスタック機能開発

フロントエンド・バックエンド・テストを分担して並行開発。

```
Create an agent team to implement the user profile feature.

Spawn three teammates:
- Frontend developer: Build the profile page UI in src/components/profile/
- Backend developer: Create the /api/users/:id endpoint in src/api/
- Test writer: Write integration tests in tests/integration/profile/

Each teammate owns their own files. The backend developer should define
the API contract first, then share it with the other two.
```

## 4. リサーチ＋設計

異なる角度から問題を探索し、設計に反映する。

```
I'm designing a CLI tool that helps developers track TODO comments
across their codebase. Create an agent team to explore this from
different angles:
- One teammate on UX and developer experience
- One on technical architecture and implementation
- One playing devil's advocate, finding potential issues

Have them discuss and converge on a design document.
```

## 5. プラン承認付きリファクタリング

大規模変更の前にプラン承認を要求する。

```
Spawn an architect teammate to refactor the authentication module.
Require plan approval before they make any changes.
Only approve plans that:
- Include migration steps for existing tokens
- Maintain backward compatibility
- Include comprehensive test coverage

After the plan is approved, spawn an implementer teammate
to execute the approved plan.
```

## 6. ドキュメント＋コード同時更新

コード変更とドキュメント更新を並行で進める。

```
Create an agent team to update the payment module.

Spawn two teammates:
- Code developer: Implement Stripe webhook handling in src/payments/
- Documentation writer: Update API docs in docs/ and add migration guide

The documentation writer should check with the code developer
about API changes before finalizing docs.
```

## 7. セキュリティ監査チーム

複数の専門領域で同時に監査を実施。

```
Create a security audit team for our web application.
Use Sonnet for each teammate.

Spawn four specialists:
- Authentication auditor: Review login, session, and token handling
- Input validation auditor: Check all user inputs and API parameters
- Dependency auditor: Scan for vulnerable packages and outdated libs
- Configuration auditor: Review server configs, env vars, and secrets

Have them share findings with each other - one auditor's finding
might reveal issues in another's domain. Compile a unified report
sorted by severity.
```

## 8. モデル混在チーム

タスクの複雑さに応じてモデルを使い分ける。

```
Create an agent team to optimize our database queries.

Spawn teammates with appropriate models:
- Use Opus for the query analyzer (complex reasoning needed)
- Use Sonnet for the implementation specialist
- Use Haiku for the benchmark runner (fast, repetitive tasks)

The analyzer identifies slow queries, the implementer optimizes them,
and the benchmark runner measures before/after performance.
```
