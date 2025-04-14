{
  config,
  pkgs,
  lib,
  ...
}: let
  prefix =
    if pkgs.stdenv.isLinux
    then "ctrl+b"
    else "ctrl+b";
in {
  # ghostty +show-config --default --docs | vim -
  home.file."${config.xdg.configHome}/ghostty/config".text =
    ''
      # osc52
      clipboard-read = allow
      # clipboard-write = allow
      # clipboard-read = deny
      # clipboard-write = deny
      clipboard-trim-trailing-spaces = true
      clipboard-paste-protection = false


      window-decoration = false
      confirm-close-surface = false
      quit-after-last-window-closed = true
      macos-option-as-alt = true
      adjust-cell-width = -1

      window-padding-x = 0
      window-padding-y = 0

      keybind = ctrl+comma=reload_config
      keybind = ctrl+equal=increase_font_size:1
      keybind = ctrl+minus=decrease_font_size:1
      keybind = ctrl+shift+v=paste_from_clipboard

      # replace tmux
      keybind = ${prefix}>space=new_split:down
      keybind = ${prefix}>h=goto_split:left
      keybind = ${prefix}>l=goto_split:right
      keybind = ${prefix}>k=goto_split:top
      keybind = ${prefix}>j=goto_split:bottom
      # keybind = ${prefix}>"=new_split:down
      keybind = ${prefix}>%=new_split:right
      keybind = ${prefix}>q=close_window
      # popup window
      keybind = ${prefix}>n=new_window
      # keybind = ${prefix}>five=new_split:right
      keybind = alt+grave_accent=toggle_quick_terminal



      # font-family = "Iosevka Term Slab Light"
      # font-family = "BlexMono Nerd Font"
      #
      # font-family = "Iosevka Term Slab Light"
      # font-family = "ZedMono Nerd Font Mono"
      # font-family = "BlexMono Nerd Font"

      palette = 0=#4f4f4f
      palette = 1=#fa6c60
      palette = 2=#a8ff60
      palette = 3=#fffeb7
      palette = 4=#96cafe
      palette = 5=#fa73fd
      palette = 6=#c6c5fe
      palette = 7=#efedef
      palette = 8=#7b7b7b
      palette = 9=#fcb6b0
      palette = 10=#cfffab
      palette = 11=#ffffcc
      palette = 12=#b5dcff
      palette = 13=#fb9cfe
      palette = 14=#e0e0fe
      palette = 15=#ffffff
      background = 000000
      foreground = f1f1f1
      cursor-color = 808080
      selection-background = b5d5ff
      selection-foreground = 000000

    ''
    + (
      if pkgs.stdenv.isDarwin
      then ''
        font-family = "IosevkaTermSlab NFM Light"
        theme = Solarized Dark Higher Contrast
      ''
      else ''''
    )
    + (
      if pkgs.stdenv.isLinux
      then ''
        font-family = "IosevkaTermSlab NFM Light"
        font-family = "IBM Plex Sans KR"
      ''
      else ''''
    );
  # + (
  #   if pkgs.stdenv.isDarwin
  #   then ''
  #     background-opacity = 0.8
  #   ''
  #   else ''''
  # );
}
