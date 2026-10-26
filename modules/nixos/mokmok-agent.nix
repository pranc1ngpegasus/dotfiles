# mokmok のエージェントデーモンを NixOS のサービスとして動かす。上流の flake が
# NixOS モジュールを公開しているので、ここではそのオプションに値を入れるだけでよい。
{ config, inputs, ... }:
{
  imports = [
    inputs.mokmok-agent.nixosModules.default
  ];

  services.mokmok-agent = {
    enable = true;

    # モデルは ollama-cloud の OpenAI 互換エンドポイントを使う。API キーは
    # シェルと同じ agenix の秘密情報を、systemd の credential 経由で渡す。
    baseUrl = "https://ollama.com/v1";
    model = "deepseek-v4.1-flash";
    apiKeyFile = config.age.secrets.ollama-api-key.path;

    # directive は毎回のリクエストの先頭に置かれるため、時刻やホスト名のように
    # 実行のたびに変わる値を含めてはならない。
    directive = ''
      You are a careful agent running unattended on a Linux host. Answer the
      request with the smallest change that solves it, and name the evidence
      behind each claim. When a request cannot be carried out, say so plainly
      instead of approximating an answer.
    '';
  };

  # agenix が秘密情報を置く前に systemd が credential を読もうとすると起動に
  # 失敗するため、復号の完了を待ってから起動する。
  systemd.services.mokmok-agent.after = [ "agenix-install-secrets.service" ];
}
