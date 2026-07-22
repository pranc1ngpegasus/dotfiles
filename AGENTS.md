# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.
このファイルはコーディングエージェントのためのクイックリファレンスです。詳細はdocs/を参照してください。

## Overview

Nix Flakes ベースの macOS (aarch64-darwin) dotfiles リポジトリ。nix-darwin と home-manager を使い、システム設定からユーザー環境まで宣言的に管理する。

## Build Commands

```bash
# flake.lock の更新
nix flake update

# システム全体の再ビルド・適用
darwin-rebuild switch --flake .#M4MacBookAir

# ビルドのみ (適用しない)
darwin-rebuild build --flake .#M4MacBookAir

# テストビルド (適用しない、プロファイルにも追加しない)
darwin-rebuild test --flake .#M4MacBookAir

# Nix コードのフォーマット
nix fmt
```

## Architecture

エントリーポイントは `flake.nix` で、主要な構成要素は以下の 4 層になっている。

- `flake/` は Flake の出力に関する定義を分離する場所で、`hosts.nix` がホストとモジュールの対応付け、`darwin-configurations.nix` が `darwinConfigurations` の生成、`formatter.nix` が formatter 出力を担当する
- `hosts/` はホスト固有の設定 (hostname, user 等) を置く場所
- `modules/` は nix-darwin のシステム設定 (firewall, keyboard, dock 等) をまとめる場所で、プラットフォーム非依存の設定は `common.nix`、macOS 固有の設定は `darwin/` に置く
- `home/` は home-manager によるユーザー環境で、`base/` が全プラットフォーム共通、`darwin/` がプラットフォーム固有

詳細は [docs/architecture.md](docs/architecture.md) を参照。

## Key Design Decisions

- nixpkgs は unstable ブランチを使用している
- Neovim nightly は neovim-nightly-overlay 経由で取得し、`modules/darwin/neovim-overlay.nix` の overlay で `pkgs.neovim-unwrapped` を nightly ビルドに差し替えている
- 1Password が SSH agent と Git の GPG 署名を担っている
- Docker ランタイムには colima を使用している
- CLI パッケージ一覧は `home/base/programs/packages.nix` に集約している (LSP など editor 用のパッケージは `home/base/editor.nix` に置く)
- Nix コードのフォーマットには nixfmt を使用している

## Conventions

- Nix モジュールを追加したら、対応する `default.nix` の imports にも追加する
- ホスト固有の設定は `hosts/<hostname>.nix` に配置し、`flake/hosts.nix` にエントリーを追加する
- 1 つの設定しか持たないディレクトリは作らず、関心ごとをファイルとして並べる
- プラットフォーム共通の設定は `home/base/` に、プラットフォーム固有の設定は `home/darwin/` に配置する
- `flake.lock` は VCS で管理し、更新時は差分をコミットする

## Writing Rules

ドキュメントやコメントを書くときは以下のルールを守ること。

- 日本語として自然な文章で書く。体言止めや電報的な箇条書きは避け、述語のある文にする
- Markdown の太字強調 (`**...**`) は使わない。強調が必要な場合はバッククォートやそのままの表現で十分に伝わるよう工夫する
- 図を描きたいときは ASCII art ではなく mermaid を使う
