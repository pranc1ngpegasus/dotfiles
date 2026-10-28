{ inputs, pkgs, ... }:
let
  pi-ollama-cloud = pkgs.buildNpmPackage rec {
    pname = "pi-ollama-cloud";
    version = "0.13.1";
    src = pkgs.fetchFromGitHub {
      owner = "fgrehm";
      repo = "pi-ollama-cloud";
      rev = "v${version}";
      hash = "sha256-zAUae474AGhSLpzxcAaHYDHkUu2qJ218SNhiSe43LgY=";
    };
    dontNpmBuild = true;
    npmDepsHash = "sha256-7SzkNXLSmM293TcOYzOj3eXtYTAd1n39fjKXp77p9JA=";
  };
in
{
  environment.systemPackages = [
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.grok
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi
    pi-ollama-cloud
    pkgs.skills
  ];
}
