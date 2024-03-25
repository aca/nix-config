{
  config,
  pkgs,
  lib,
  ...
}: {
  home.file."${config.xdg.configHome}/ghostty/config".text = ''
window-decoration = false
macos-option-as-alt = true
adjust-cell-width = -1

window-padding-x = 0
window-padding-y = 0

keybind = ctrl+comma=reload_config
keybind = ctrl+equal=increase_font_size:1
keybind = ctrl+minus=decrease_font_size:1
keybind = ctrl+shift+v=paste_from_clipboard

font-family	= Iosevka Term Slab Light

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
'' + (
if pkgs.stdenv.isDarwin then ''
background-opacity = 0.8
'' else ''''
  );
}
