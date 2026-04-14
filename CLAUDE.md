# MindOrganizer — マインド整理アプリ

頭の中のモヤモヤをツリー形式で構造化・可視化するiOSアプリ。

> 変更履歴は CHANGELOG.md に記録。TODO は todo.md に分離。

## 技術スタック

- SwiftUI + SwiftData（iOS 17+）
- @Observable マクロ（Observation framework）
- Firebase Auth（Apple / Google Sign-In）+ Cloud Firestore（Phase 2〜）
- WidgetKit + App Group（Phase 4）

## アーキテクチャ: MVVM + Repository

```
View (SwiftUI) → ViewModel (@Observable) → Repository (Protocol)
                                            ├── LocalRepository (SwiftData)
                                            └── RemoteRepository (Firestore)
```

Repository を Protocol で抽象化し、ViewModel はデータソースを意識しない。

## ディレクトリ構成

| ディレクトリ | 役割 |
|-------------|------|
| App/ | AppState, Router, DI |
| Models/ | SwiftData @Model + Firestore DTO |
| Views/Auth/ | 認証画面 |
| Views/Home/ | テーマ一覧（メイン画面） |
| Views/TreeEditor/ | ★コア：ツリー編集画面 |
| Views/ThemeList/ | 全テーマ一覧 |
| Views/Search/ | 全文検索 |
| Views/Snapshot/ | スナップショット |
| Views/Settings/ | 設定・アカウント |
| Views/Components/ | 共通UIパーツ |
| Repositories/ | Local / Remote / Synced 実装 |
| Services/ | Sync, Snapshot, Export |
| Extensions/ | Swift 拡張 |
| Resources/ | Assets, Localizable |
| Widget/ | WidgetKit 拡張 |

## 設計原則（WHY）

- **ローカル優先**: SwiftData が Source of Truth。オフラインでも全機能動作させるため
- **UIライブラリ不使用**: SwiftUI 標準のみで構築。外部依存を最小化し審査リスクを減らす
- **ゲストモード必須**: App Store 審査 5.1.1 対応。ログインなしで全ローカル機能を提供
- **NavigationStack（TabView不使用）**: 思考の「深掘り」UXにスタック型ナビゲーションが合致
- **ツリーのフラット配列変換**: 深さ優先でフラット化し List で描画。標準 List API（スワイプ、ドラッグ）を活用

## コーディング規約

- Swift 5.9+、iOS 17+ API を使用
- `@Observable` マクロを使用（`ObservableObject` は使わない）
- View は可能な限り小さく分割し、Views/Components/ に共通パーツを配置
- 命名: キャメルケース、Protocol は `-able` / `-ing` サフィックス
- エラーハンドリング: `do-catch` + ユーザー向けアラート表示。`try!` / `fatalError` は禁止
- 日本語コメントOK、ただし公開APIのドキュメントコメントは英語

## データ制約

- 1テーマあたりノード上限: 1,000（Firestore 1MB ドキュメント制限）
- ノードテキスト: 最大1,000文字 / メモ: 最大5,000文字
- ツリー深さ: 最大20階層
- インデント: depth × 24pt

## コマンド

| コマンド | 説明 |
|---------|------|
| `Cmd+B` | Xcode ビルド |
| `Cmd+U` | Xcode テスト実行 |
| `swift build` | CLI ビルド確認 |

## 現在のフェーズ

**Phase 2: Firebase Auth + クラウド同期** — Phase 1 MVP完了済み

## 参考ドキュメント

- 要件定義書: MindOrganizer_Requirements_v1.0.docx
- 変更履歴: CHANGELOG.md
- タスク管理: todo.md
