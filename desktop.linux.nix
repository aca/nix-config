{
  config,
  pkgs,
  lib,
  nixpkgs,
  inputs,
  system,
  ...
}:
let
in
{
  imports = [
    # ./env.nix
    # ./dev/default_ssh.nix
    # ./pkgs/scripts.nix
    # ./pkgs/tmux/tmux.nix
  ];

  environment.systemPackages = [
    pkgs.element-desktop
    pkgs.zathura
    pkgs.elvish
  ];

  # Set your time zone.
  time.timeZone = "Asia/Seoul";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    # enable = true;
    inputMethod = {
      enable = true;
      type = "kime";
      kime = {
        # extraConfig = ''
        #   daemon:
        #     modules:
        #     - Wayland
        #     - Xim
        #   indicator:
        #     icon_color: Black
        #   log:
        #     global_level: DEBUG
        #   engine:
        #     translation_layer: null
        #     default_category: Latin
        #     global_category_state: false
        #     global_hotkeys:
        #       M-C-Backslash:
        #         behavior: !Mode Math
        #         result: ConsumeIfProcessed
        #       Super-Space:
        #         behavior: !Toggle
        #         - Hangul
        #         - Latin
        #         result: Consume
        #       M-C-E:
        #         behavior: !Mode Emoji
        #         result: ConsumeIfProcessed
        #       Esc:
        #         behavior: !Switch Latin
        #         result: Bypass
        #       Muhenkan:
        #         behavior: !Toggle
        #         - Hangul
        #         - Latin
        #         result: Consume
        #       Hangul:
        #         behavior: !Toggle
        #         - Hangul
        #         - Latin
        #         result: Consume
        #     category_hotkeys:
        #       Hangul:
        #         ControlR:
        #           behavior: !Mode Hanja
        #           result: Consume
        #         HangulHanja:
        #           behavior: !Mode Hanja
        #           result: Consume
        #         F9:
        #           behavior: !Mode Hanja
        #           result: ConsumeIfProcessed
        #     mode_hotkeys:
        #       Math:
        #         Enter:
        #           behavior: Commit
        #           result: ConsumeIfProcessed
        #         Tab:
        #           behavior: Commit
        #           result: ConsumeIfProcessed
        #       Hanja:
        #         Enter:
        #           behavior: Commit
        #           result: ConsumeIfProcessed
        #         Tab:
        #           behavior: Commit
        #           result: ConsumeIfProcessed
        #       Emoji:
        #         Enter:
        #           behavior: Commit
        #           result: ConsumeIfProcessed
        #         Tab:
        #           behavior: Commit
        #           result: ConsumeIfProcessed
        #     candidate_font: Noto Sans CJK KR
        #     xim_preedit_font:
        #     - Noto Sans CJK KR
        #     - 15.0
        #     latin:
        #       layout: Qwerty
        #       preferred_direct: true
        #     hangul:
        #       layout: dubeolsik
        #       word_commit: false
        #       preedit_johab: Needed
        #       addons:
        #         all:
        #         - ComposeChoseongSsang
        #         dubeolsik:
        #         - TreatJongseongAsChoseong
        # '';
      };
      # kime.config = {
      #   indicator.icon_color = "White";
      # };
    };
  };
}
