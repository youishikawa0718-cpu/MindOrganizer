---
paths:
  - "**/TreeEditor/**"
---

# TreeEditor 実装ルール

- ツリーは深さ優先でフラット配列に変換し、`List` / `LazyVStack` で描画
- 各行のインデント: `depth × 24pt` の `leading padding`
- 折り畳み状態は `ThoughtNode.isCollapsed` で管理
- ノードの追加・削除・並べ替え後は必ず `rebuildFlatNodes()` を呼ぶ
- 標準の List API（スワイプ削除、コンテキストメニュー）を活用
- ViewModel (`TreeEditorViewModel`) にロジックを集約し、View は描画のみ
