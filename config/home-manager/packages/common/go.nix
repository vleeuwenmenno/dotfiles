{
  config,
  pkgs,
  pkgs-go,
  ...
}:
{
  programs.go = {
    enable = true;
    package = pkgs-go.go;
  };
}
