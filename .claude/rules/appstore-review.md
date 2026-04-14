---
paths:
  - "**/Auth/**"
  - "**/Settings/**"
---

# App Store 審査対策ルール

- ゲストモード必須: ログインなしで全ローカル機能を使用可能にする (5.1.1)
- Apple Sign-In 必須: Google Sign-In と併用する場合は必ず提供 (4.8)
- アカウント削除機能: Settings に実装。Firebase Auth + Firestore データ完全削除 (5.1.1(v))
- プライバシーポリシー: アプリ内からリンク (5.1.2)
- ATT: Firebase Analytics を入れる場合は ATT 許可取得が必要
- タバコ関連コンテンツは一切含めない (1.4.3)
