{ config, lib, nixpkgs, ... }: {
  imports = [
    ../../roles/linux
    ../../roles/users
    ./hardware-configuration.nix
  ];

  jade.rootSshKeys.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPefOkO/ES/9glugzWNTS3yZeNYNAgPKtmoZBk3uH4FMJN2EYsv4Ngd6XFtRGD+3rpJYrBXNnoVxhUNn6KtoFD8= jade@snowflake"
  ];

  virtualisation.vmVariant = {
    virtualisation.forwardPorts = [
      {
        from = "host";
        host.port = 2222;
        guest.port = 22;
      }
    ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "micro";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
