{ config, pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      sops
      age
      age-plugin-se
    ];

    # sops が age 識別ファイルを探す場所を XDG 配下に固定する。
    # age-plugin-se で生成した identity (Secure Enclave へのハンドル) をここに置く。
    sessionVariables = {
      SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    };
  };

  # direnv stdlib に `use sops` を生やす。
  # プロジェクトの `.envrc` に `use sops` と書くだけで、暗号化された
  # secrets ファイルを復号して環境変数として export できる。
  programs.direnv.stdlib = ''
    # use_sops [path]
    #   sops で暗号化された YAML/JSON/dotenv を復号し、direnv の dotenv loader に流し込む。
    #   path を省略した場合は secrets.sops.yaml を見る。
    use_sops() {
      local path=''${1:-secrets.sops.yaml}
      if [[ ! -f "$path" ]]; then
        log_error "use sops: file not found: $path"
        return 1
      fi
      watch_file "$path"

      # SOPS_AGE_KEY_FILE は home.sessionVariables でも設定しているが、
      # darwin-rebuild 直後に shell を reload していない場合や、direnv が継承する
      # 環境にまだ反映されていない場合に備えて、関数内でも同じ既定値を補う。
      local key_file=''${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}
      if [[ ! -f "$key_file" ]]; then
        log_error "use sops: age identity not found at $key_file. Generate one with: age-plugin-se keygen --access-control any-biometry-and-passcode -o $key_file"
        return 1
      fi

      local fmt
      case "$path" in
        *.json) fmt=json ;;
        *.yaml | *.yml) fmt=yaml ;;
        *) fmt=dotenv ;;
      esac

      # 平文を fs に落とす時間を最小化するため、TMPDIR (mktemp は mode 600) を経由して
      # direnv の dotenv loader に渡したあとすぐに削除する。
      local tmpfile
      tmpfile=$(mktemp -t direnv-sops.XXXXXX) || return 1
      if ! SOPS_AGE_KEY_FILE="$key_file" sops decrypt --input-type "$fmt" --output-type dotenv "$path" > "$tmpfile"; then
        rm -f "$tmpfile"
        log_error "use sops: failed to decrypt $path"
        return 1
      fi
      dotenv "$tmpfile"
      rm -f "$tmpfile"
    }
  '';
}
