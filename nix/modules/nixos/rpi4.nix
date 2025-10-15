{ lib, pkgs, ... }:

{
  # thanks to fzakaria.com - https://fzakaria.com/2024/08/13/nixos-raspberry-pi-me
  boot.supportedFilesystems.zfs = lib.mkForce false;
  sdImage.compressImage = false;
  hardware.raspberry-pi."4".touch-ft5406.enable = false;

  nixpkgs.overlays = [
    # Workaround: https://github.com/NixOS/nixpkgs/issues/154163
    # modprobe: FATAL: Module sun4i-drm not found in directory
    (_final: super: {
      makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  hardware.enableRedistributableFirmware = true;
}
