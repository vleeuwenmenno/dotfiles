{ config, pkgs, ... }:
{
  # Enable NetworkManager with Wireguard support
  networking = {
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-vpnc
        networkmanager-openvpn
      ];
    };
  };

  # Add NetworkManager connection profiles
  environment.etc."NetworkManager/system-connections/work-vpn.nmconnection".source = "${config.home.homeDirectory}/dotfiles/secrets/wireguard/work.wg0.conf";

  # Ensure NetworkManager Wireguard support is installed
  environment.systemPackages = with pkgs; [
    networkmanager-wireguard
    wireguard-tools
  ];

  # Add a systemd service to set proper permissions and reload NetworkManager connections
  systemd.services.reload-networkmanager-connections = {
    description = "Set permissions and reload NetworkManager Connections";
    wantedBy = [ "multi-user.target" ];
    after = [ "NetworkManager.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "reload-nm-connections" ''
        chmod 600 /etc/NetworkManager/system-connections/*
        ${pkgs.networkmanager}/bin/nmcli connection reload
      '';
    };
  };
}
