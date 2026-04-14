---
paths:
  - "**/Repositories/**"
  - "**/Services/SyncService.swift"
  - "**/FirestoreDTO/**"
---

# Firebase 同期ルール

- ローカル (SwiftData) が Source of Truth。オフラインでも全機能動作
- Firestore のノードはサブコレクションではなく配列で格納（1ドキュメント読み取りで完結）
- コンフリクト解決: Last Write Wins（`updatedAt` 比較）
- `NWPathMonitor` でネットワーク復帰を検知し自動同期
- DTO は `Sendable` 準拠。Repository は `@MainActor` を付与
- Firestore ドキュメントサイズ上限 1MB に注意（ノード数1,000が実質上限）
