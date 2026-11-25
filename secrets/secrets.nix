let
  m4macbookair = "age1lumpac7m5fkv33rq287faf56f2fx9y2qjlhlcexmjm4evacgef9sugdff5";
  nixos = "age1p3g3fmjvt8p87pfg3mnzpw7z88g7c64kgw8y65uf5mcsvufs8gas2cr8kh";
in
{
  "ollama-api-key.age".publicKeys = [
    m4macbookair
    nixos
  ];
}
