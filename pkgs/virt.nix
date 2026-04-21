{
  config,
  pkgs,
  options,
  inputs,
  lib,
  ...
}: {
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      runAsRoot = true;
      swtpm.enable = true;
      # ovmf = {
      #   enable = true;
      #   packages = [
      #     (pkgs.OVMF.override {
      #       secureBoot = true;
      #       tpmSupport = true;
      #     }).fd
      #   ];
      # };
    };
  };
  virtualisation.spiceUSBRedirection.enable = true;
}

