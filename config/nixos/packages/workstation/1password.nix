{ pkgs, ... }:
{
  # 1Password
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "menno" ];
  };

  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ''
        firefox
        brave
        zen
      '';
      mode = "0755";
    };
  };
}
