# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.
このファイルはコーディングエージェントのためのクイックリファレンスです。詳細はdocs/を参照してください。

## Overview

Nix Flakes ベースの dotfiles リポジトリ。macOS (aarch64-darwin) は nix-darwin で、NixOS (x86_64-linux) は NixOS モジュールで構成し、どちらも home-manager でユーザー環境を管理する。全プラットフォーム共通の設定は `modules/` 直下と `home/base/` に置き、OS 固有の設定だけを `modules/darwin`、`modules/nixos`、`home/darwin`、`home/linux` に分ける。

## Build Commands

```bash
# flake.lock の更新
nix flake update

# macOS: ビルドのみ / 適用
darwin-rebuild build --flake .#M4MacBookAir
darwin-rebuild switch --flake .#M4MacBookAir

# NixOS: ビルドのみ / 適用
nixos-rebuild build --flake .#nixos
sudo nixos-rebuild switch --flake .#nixos

# Nix コードのフォーマット
nix fmt
```

## Architecture

エントリーポイントは `flake.nix` で、主要な構成要素は以下の 4 層になっている。

- `flake.nix` は inputs と `darwinConfigurations`、`nixosConfigurations`、`perSystem` (devShell、treefmt、pre-commit) を定義する。各構成には `specialArgs` で `inputs` と `isDarwin` を渡す
- `hosts/` はホスト固有の設定 (hostPlatform、hostName、`my.primaryUser`、ユーザーアカウント) を置く場所である
- `modules/` はシステム設定をまとめる場所で、直下が全プラットフォーム共通、`darwin/` と `nixos/` が OS 固有である
- `home/` は home-manager によるユーザー環境で、`base/` が全プラットフォーム共通、`darwin/` と `linux/` が OS 固有である

詳細は [docs/architecture.md](docs/architecture.md) を参照。

## Key Design Decisions

- nixpkgs は FlakeHub の rolling チャンネル (`https://flakehub.com/f/NixOS/nixpkgs/0.1`) を追従している
- Nix の配布は両 OS とも Determinate Nix を使い、flake input の `determinate` モジュールで宣言的に構成する。詳細は [docs/determinate-nix.md](docs/determinate-nix.md) を参照
- Neovim nightly は neovim-nightly-overlay 経由で取得し、`modules/neovim-overlay.nix` の overlay で `pkgs.neovim-unwrapped` を nightly ビルドに差し替えている
- GitHub への認証は `gh auth git-credential` による HTTPS 認証を使う。macOS の Git 署名は nix-secure-enclave-key で Secure Enclave 内の鍵を使って行い、秘密鍵をディスクに置かない
- Docker は macOS では colima、NixOS では `virtualisation.docker` を使う
- CLI パッケージ一覧は `home/base/programs/packages.nix` に集約している (LSP など editor 用のパッケージは `home/base/editor.nix` に置く)
- Nix コードのフォーマットには nixfmt を使用している

## Conventions

- Nix モジュールを追加したら、対応する `default.nix` の imports にも追加する
- ホスト固有の設定は `hosts/<hostname>.nix` に配置し、`flake.nix` の対応する構成にエントリーを追加する
- 全プラットフォーム共通の設定は `modules/` 直下または `home/base/` に、OS 固有の設定は `modules/<os>/` または `home/<os>/` に配置する
- 1 つの設定しか持たないディレクトリは作らず、関心ごとをファイルとして並べる
- モジュールの `imports` を `pkgs` で条件分岐すると評価が循環するため、OS の判定には `specialArgs` の `isDarwin` を使う
- `flake.lock` は VCS で管理し、更新時は差分をコミットする

## Writing Rules

ドキュメントやコメントを書くときは以下のルールを守ること。

- 日本語として自然な文章で書く。体言止めや電報的な箇条書きは避け、述語のある文にする
- Markdown の太字強調 (`**...**`) は使わない。強調が必要な場合はバッククォートやそのままの表現で十分に伝わるよう工夫する
- 図を描きたいときは ASCII art ではなく mermaid を使う
