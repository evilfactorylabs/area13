{
  maintainers,
  inputs,
  ezModules,
  pkgs,
  ...
}:

{
  system.stateVersion = "25.05";

  imports = with ezModules; [
    # using for creating sd image
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    # hardware support for raspberry pi 4
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    # our hardware configuration for raspberry pi 4
    rpi4
  ];

  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nixpkgs = {
    hostPlatform = "aarch64-linux";
    config = {
      allowUnfree = true;
    };
  };

  networking = {
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [
      22
      80
    ];
    hostName = "komunix";
  };

  time.timeZone = "Asia/Jakarta";

  users.users.komunix = {
    isNormalUser = true;
    shell = pkgs.bash;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    description = "Komunix.org";
    openssh.authorizedKeys.keys = maintainers.getMaintainerKeysByRole "core";
    # Allow the graphical user to login without password
    initialHashedPassword = "";
  };

  services.openssh = {
    enable = true;
    banner = ''

       _   __                            _      
      | | / /                           (_)     
      | |/ /  ___  _ __ ___  _   _ _ __  ___  __
      |    \ / _ \| '_ ` _ \| | | | '_ \| \ \/ /
      | |\  \ (_) | | | | | | |_| | | | | |>  < 
      \_| \_/\___/|_| |_| |_|\__,_|_| |_|_/_/\_\
                                                
          ;/nix/store/milik-bersama;

    '';
  };

  # add swap
  swapDevices = [
    {
      device = "/swapfile";
      size = 2048;
    }
  ];

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  # simplify sudo
  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };

  # Allow the user to log in as root without a password.
  users.users.root.initialHashedPassword = "";
}
