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

エントリーポイントは `flake.nix` で、主要な構成要素は以下の 3 層になっている。

- `hosts/` はホスト固有の設定 (hostname, user) を置く場所
- `modules/` は nix-darwin のシステム設定 (firewall, keyboard, dock 等) をまとめる場所
- `home/` は home-manager によるユーザー環境で、`base/` が全プラットフォーム共通、`darwin/` がプラットフォーム固有

詳細は [docs/architecture.md](docs/architecture.md) を参照。

## Key Design Decisions

- nixpkgs は unstable ブランチを使用している
- Neovim nightly は neovim-nightly-overlay 経由で取得し、`flake.nix` の packages として公開している
- 1Password が SSH agent と Git の GPG 署名を担っている
- Docker ランタイムには colima を使用している
- パッケージ一覧は `home/base/programs/default.nix` に集約している
- Nix コードのフォーマットには nixfmt を使用している

## Conventions

- Nix モジュールを追加したら、対応する `default.nix` の imports にも追加する
- ホスト固有の設定は `hosts/<hostname>/` に配置する
- プラットフォーム共通の設定は `home/base/` に、プラットフォーム固有の設定は `home/darwin/` に配置する
- `flake.lock` は `.gitignore` で除外されている

## Writing Rules

ドキュメントやコメントを書くときは以下のルールを守ること。

- 日本語として自然な文章で書く。体言止めや電報的な箇条書きは避け、述語のある文にする
- Markdown の太字強調 (`**...**`) は使わない。強調が必要な場合はバッククォートやそのままの表現で十分に伝わるよう工夫する
- 図を描きたいときは ASCII art ではなく mermaid を使う
