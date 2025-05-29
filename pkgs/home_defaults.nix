{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    # ./home.ghostty.nix
    ./alacritty/home.alacritty.nix
    ./home.gitconfig.nix
    ./elvish/elvish.nix
  ];

  xdg.configFile."user-tmpfiles.d/default.conf".text = ''
d %h/bin 0755 - - -
d %h/bin22 0755 - - -
d %h/src 0755 - - -
d %h/.local/share/nvim/site 0755 - - -
d %h/.ssh 0755 - - -
d %h/.config/vifm 0755 - - -
d %h/.config/fish 0755 - - -
d %h/.local/Trash 0755 - - -
d %h/.kube 0755 - - -
d %h/.aws 0755 - - -
  '';

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # services.pueue = {
  #   enable = true;
  #   settings = {
  #     client = {
  #       dark_mode = true;
  #       show_expanded_aliases = false;
  #     };
  #     daemon = {
  #       default_parallel_tasks = 1;
  #       pause_group_on_failure = false;
  #       pause_all_on_failure = false;
  #     };
  #     shared = {
  #       use_unix_socket = true;
  #     };
  #   };
  # };

  home.file."${config.home.homeDirectory}/.inputrc".text = ''
    set enable-bracketed-paste Off

    # disable quoted-insert
    "\C-v": ""

    set bell-style visible

    # By default, if filename completion is performed on a symbolic link pointing
    # to a directory, append a slash.
    set mark-symlinked-directories

    # Hit tab to show a list of possible completions, ignoring case>
    set completion-ignore-case
    set show-all-if-ambiguous
    set visible-stats
    set Colored-stats

    # Using the Up/Down arrow keys.
    "\e[A": history-search-backward
    "\e[B": history-search-forward

    # Enable 8-bit input (do not strip 8th bit from input).
    set meta-flag

    # Synonym for meta-flag.
    set input-meta

    # Display 8-bit characters directly (rather than as a meta-prefixed escape sequence).
    set output-meta

    # Do not convert 8-bit characters into ASCII key sequences.
    set convert-meta off

    set vi-ins-mode-string \033[1;31m<(ins)>\033[0m \1\e[5 q\2
    set vi-cmd-mode-string \033[1;30m<(cmd)>\033[0m \1\e[1 q\2
  '';
  home.file."${config.home.homeDirectory}/.curlrc".text = ''
    insecure
  '';
  home.file."${config.home.homeDirectory}/.sqliterc".text = ''
    .headers on
    .mode column
  '';
  home.file."${config.home.homeDirectory}/.npmrc.global".text = ''
    prefix=~/
  '';
  home.file."${config.xdg.configHome}/aria2/aria2.conf".text = ''
    auto-file-renaming=false
    user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3602.2 Safari/537.36
    seed-time=0
    rpc-save-upload-metadata=false
    max-upload-limit=1K
    max-overall-upload-limit=1K
    max-download-limit=5M
    max-concurrent-downloads=100
    check-certificate=false
  '';

  home.file."${config.xdg.configHome}/bat/config".text = ''
      # Set the theme to "TwoDark"
    --theme="1337"

    # Show line numbers, Git modifications and file header (but no grid)
    # --style="numbers,changes,header"
    # --style="plain"

    # Use italic text on the terminal (not supported on all terminals)
    --italic-text=always

    # Add mouse scrolling support in less (does not work with older
    # versions of "less")
    # --pager="less -FR"

    # Use C++ syntax (instead of C) for .h header files
    # --map-syntax h:cpp

    # Use "gitignore" highlighting for ".ignore" files
    # --map-syntax .ignore:.gitignore
  '';

  home.file."${config.xdg.configHome}/fd/ignore".text = ''
      vendor
    .git
    .stfolder
    .sync
    node_modules
    .DocumentRevisions-V100
    .cache
    .Trash-502
    .parcel-cache
    dist
    @eaDir
  '';

  home.file."${config.xdg.configHome}/ripgrep/rc".text = ''
    --smart-case
    --follow
    --hidden

    --colors=line:fg:243
    --colors=line:style:nobold
    --colors=path:fg:243
    --colors=path:style:nobold
    --colors=match:fg:black
    --colors=match:bg:yellow
    --colors=match:style:nobold

    # --glob=!.stfolder/**
    # --glob=!.DocumentRevisions-V100/**
    # --glob=!.git/**
    # --glob=!vendor/**
    # --glob=!**/vendor/**
    # --glob=!node_modules/**
    # --glob=!.parcel-cache/**
    # --glob=!yarn.lock
    # --glob=!package.json
    # --glob=!dist/**
    # --glob=!fish_history
  '';
  home.file."${config.xdg.configHome}/yt-dlp/config".text = builtins.readFile ./youtube-dl;
  home.file."${config.xdg.configHome}/youtube-dl/config".text = builtins.readFile ./youtube-dl;

  home.file."${config.xdg.configHome}/git/gitignore".text =
    builtins.readFile ./git/gitignore;

  # screenshot
    # effect-blur=13x13
    # effect-vignette=0.5:0.5
    # fade-in=0.4
  # home.file."${config.xdg.configHome}/swaylock/config".text = ''
  # '';

  # # virt-manager
  # dconf.settings = {
  #   "org/virt-manager/virt-manager/connections" = {
  #     autoconnect = ["qemu:///system"];
  #     uris = ["qemu:///system"];
  #   };
  # };

  # home.file."${config.xdg.configHome}/nvim/init.lua".source = (pkgs.runCommand "init.luab" {
  # buildInputs = [ pkgs.luajit pkgs.luajitPackages.stdlib ];
  # source = ./nvim/init.lua;
  # }
  # ''
  #   cat $source | luajit -b - - > $out
  # ''
  # );
}
