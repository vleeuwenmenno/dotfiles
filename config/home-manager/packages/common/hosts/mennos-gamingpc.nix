{ pkgs-unstable, ... }:
{
  home.packages = with pkgs-unstable; [ ollama-rocm ];
}
