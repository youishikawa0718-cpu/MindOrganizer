---
paths:
  - "**/*.swift"
---

# Swift コーディングルール

- `@Observable` マクロを使用。`ObservableObject` / `@Published` は使わない
- `any` 型は禁止、`unknown` または具体型を使う
- エラーは `do-catch` で処理し、ユーザー向けアラートを表示。`try!` / `fatalError` は禁止
- SwiftData の `@Model` で永続化。`@Attribute(.unique)` でID重複防止
- Swift Concurrency: `async/await` を使用。コールバックベースのAPIは避ける
- Swift 6 strict concurrency: `@MainActor` を適切に付与し、Sendable準拠を確保
