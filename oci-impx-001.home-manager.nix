{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
  # dotfiles = builtins.fetchGit {
  #   url = "https://github.com/aca/dotfiles";
  #   ref = "main";
  #   inherit (inputs.dotfiles) rev;
  #   submodules = true;
  # };
in {
  imports = [
    ./pkgs/vifm/vifmrc.nix
    ./pkgs/home_defaults.nix
  ];

  home.stateVersion = "25.05";
  home.username = "rok";
  home.homeDirectory = "/home/rok";

  # home.file.".local/share/nvim/site".source = "${dotfiles.outPath}/.local/share/nvim/site";
  # home.file."${config.xdg.configHome}/nvim".source = "${dotfiles.outPath}/.config/nvim";
  # home.file.".config/mpv".source = "${dotfiles.outPath}/.config/mpv";

  # https://github.com/nix-community/home-manager/issues/355#issuecomment-524042996
  # Note to other users: the problem of old services being never deleted can be avoided by setting
  # systemd.user.startServices to true, if no services have failed yet.
  # Otherwise, you need to systemctl --user reset-failed the degraded services before calling home-manager.
  systemd.user.startServices = true;
}
