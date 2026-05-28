{
  modulesPath,
  ...
}:

{

  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.kernelModules = [ "kvm-amd" ];
  # Fix for Fn keys on keychron
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=0
  '';

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  fileSystems."/media/extra" = {
    device = "/dev/disk/by-label/Extra";
    fsType = "ext4";
  };

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];
}
