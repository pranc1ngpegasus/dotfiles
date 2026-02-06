# Nix Flake 管理外のツール

このドキュメントでは、nix flake (`flake.nix`) の管理外で別途インストールが必要なツールを列挙する。

## 1Password

- 用途: パスワードマネージャー / SSH エージェント / Git コミット署名
- 詳細: SSH 秘密鍵を 1Password 内に保管し、SSH エージェントとして動作する。秘密鍵がアプリ外に出ることなく Touch ID で認証できる。Git の GPG 署名 (SSH 形式) にも対応
- 公式: https://1password.com/
- インストール: macOS アプリとして手動インストール
- 設定箇所:
  - `home/base/programs/ssh/default.nix` (SSH Identity Agent)
  - `home/base/programs/git/default.nix` (GPG 署名)

## Google Chrome

- 用途: Web ブラウザ
- 公式: https://www.google.com/chrome/
- インストール: macOS アプリとして手動インストール

## Choosy

- 用途: macOS のデフォルトブラウザとして設定し、リンクを開く際にルールベースで使用するブラウザやプロファイルを振り分ける
- 詳細: URL パターンなどの条件に基づいてリンクを開くブラウザ / プロファイルを自動選択できる。Google Chrome、Microsoft Edge、Brave、Vivaldi のプロファイル選択に対応
- 公式: https://choosy.app/
- インストール: macOS アプリとして手動インストール

## Ghostty

- 用途: GPU アクセラレーション対応のターミナルエミュレータ
- 詳細: macOS では Metal によるGPU レンダリングを使用。プラットフォームネイティブな UI、タブ・分割ペイン、Kitty graphics/keyboard protocol、Nerd Fonts のビルトインサポートなどを備える
- 公式: https://ghostty.org/
- インストール: macOS アプリとして手動インストール

## Karabiner-Elements

- 用途: macOS 向けキーボードカスタマイズツール
- 詳細: キーの単純なリマップ (Simple Modifications) と、条件付きの複雑なルール (Complex Modifications) に対応。特定のキーボードのみへの適用や複数プロファイルの切り替えが可能。Intel / Apple Silicon 両対応
- 公式: https://karabiner-elements.pqrs.org/
- インストール: macOS アプリとして手動インストール
