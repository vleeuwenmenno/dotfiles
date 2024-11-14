{
  lib,
  config,
  pkgs,
  ...
}:
{
  # Copy search engine configuration script
  home.file.".local/bin/brave-search-engines.sh" = {
    source = ./brave-search-engines.sh;
    executable = true;
  };

  # Run search engine configuration script
  home.activation = {
    setBraveSearchEngines = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      PATH="${pkgs.procps}/bin:${pkgs.sqlite}/bin:$PATH" $HOME/.local/bin/brave-search-engines.sh
    '';
  };

  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      { id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; } # 1password
      { id = "oldceeleldhonbafppcapldpdifcinji"; } # language tool
      { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # sponsor block
      { id = "gebbhagfogifgggkldgodflihgfeippi"; } # return youtube dislike
      { id = "neebplgakaahbhdphmkckjjcegoiijjo"; } # keepa
      { id = "dnhpnfgdlenaccegplpojghhmaamnnfp"; } # augmented steam
      { id = "fihnjjcciajhdojfnbdddfaoknhalnja"; } # I don't care about cookies
      { id = "gphhapmejobijbbhgpjhcjognlahblep"; } # gnome shell integration
      { id = "eadndfjplgieldjbigjakmdgkmoaaaoc"; } # xdebug helper
    ];
    commandLineArgs = [ ];
  };
}
