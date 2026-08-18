# Nix Flake 管理外のツール

このドキュメントでは、nix flake (`flake.nix`) の管理外で別途インストールが必要なツールを列挙する。

## 1Password

- 用途: パスワードマネージャー
- 詳細: 各サービスのパスワードや認証情報の保管に使う。SSH エージェントや Git コミット署名には使わず、Git の署名は Secure Enclave 内の鍵 (nix-secure-enclave-key) で行う
- 公式: https://1password.com/
- インストール: macOS アプリとして手動インストール

## Google Chrome

- 用途: Web ブラウザ
- 公式: https://www.google.com/chrome/
- インストール: macOS アプリとして手動インストール

## Choosy

- 用途: macOS のデフォルトブラウザとして設定し、リンクを開く際にルールベースで使用するブラウザやプロファイルを振り分ける
- 詳細: URL パターンなどの条件に基づいてリンクを開くブラウザ / プロファイルを自動選択できる。Google Chrome、Microsoft Edge、Brave、Vivaldi のプロファイル選択に対応
- 公式: https://choosy.app/
- インストール: macOS アプリとして手動インストール

## Karabiner-Elements

- 用途: macOS 向けキーボードカスタマイズツール
- 詳細: キーの単純なリマップ (Simple Modifications) と、条件付きの複雑なルール (Complex Modifications) に対応。特定のキーボードのみへの適用や複数プロファイルの切り替えが可能。Intel / Apple Silicon 両対応
- 公式: https://karabiner-elements.pqrs.org/
- インストール: macOS アプリとして手動インストール
