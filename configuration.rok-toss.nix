# https://nixos.org/guides/nix-pills/
{
  config,
  pkgs,
  options,
  ...
}: {
  imports = [
    ./dev/go.nix
    ./dev/python.nix
    ./dev/default.nix
  ];

  # environment.variables = rec {
  #   LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [pkgs.oracle-instantclient];
  # };

  nix.settings = {
    experimental-features = "nix-command flakes";
    trusted-users = ["rok" "kyungrok.chung"];
  };

  services.nix-daemon.enable = true;

  fonts = {
    fontDir = {
        enable = true;
    };
    fonts = [
      pkgs.dejavu_fonts
      pkgs.monaspace
      pkgs.mona-sans
      pkgs.hubot-sans
      pkgs.mona-sans
    ];
  };

  homebrew = {
    enable = true;
    taps = [
      "laishulu/macism"
      "aca/tap"
      "zegervdv/zathura"
      "homebrew/cask-versions" # wezterm
      # "encoredev/tap/encore"
      # "chipmk/tap/docker-mac-net-connect"
    ];
    brews = [
      "laishulu/macism/macism"
      "zegervdv/zathura/zathura-pdf-poppler"
      "aca/tap/agec"
      "mas"
      "mupdf"
      # "act"
      # "age"
      # "atool"
      # "automake"
      # "awscli"
      # "azure-cli"
      # "bash-completion@2"
      # "bkt"
      # "black"
      # "blueutil"
      # "caddy"
      # "cargo-bundle"
      # "cdk8s"
      # "cdktf"
      # "certbot"
      # "cfssl"
      # "choose-rust"
      # "cloudflared"
      # "cmocka"
      # "colima"
      # "croc"
      # "crystal"
      # "curl"
      # "deno"
      # "dhall"
      # "diffr"
      # "diskus"
      # "dive"
      # "docker"
      # "docker-buildx"
      # "duckdb"
      # "dura"
      # "eksctl"
      # "emscripten"
      # "expect"
      # "freeglut"
      # # "fzf"
      # "gawk"
      # "gcalcli"
      # "gh"
      # "ghq"
      # "git"
      # "git-annex"
      # "git-delta"
      # # "git-flow"
      # # "git-lfs"
      # "glances"
      # "gnuplot"
      # "grafana"
      # "graphviz"
      # "guile"
      # "helix"
      # "helm"
      # "hexyl"
      # "hwatch"
      # "hyperfine"
      # "imagemagick"
      # "iproute2mac"
      # "istioctl"
      # "jless"
      # "jpeg"
      # "jansson"
      # "jc"
      # "jo"
      # "k6"
      # "k9s"

      # "kotlin"
      # "ki"
      #
      # "krew"
      # "kustomize"
      # # "lazygit"
      # "libvirt"
      # "llvm"
      # "mas"
      # "meson"
      # "minikube"
      # "mitmproxy"
      # "mkcert"
      # "moreutils"
      # "multitail"
      # "mupdf"
      # # "mysql"
      # # "postgresql"
      # "ncc"
      # "ncdu"
      # "neomutt"
      # "nghttp2"
      # "nginx"
      # "noti"
      # "openapi-generator"
      # "openlibm"
      # "openssh"
      # "p7zip"
      # "pandoc"
      # "pastel"
      # "perl"
      # "pgcli"
      # "pngpaste"
      # "pnpm"
      # "qt@5"
      # "prometheus"
      # "pstree"
      # "pueue"
      # "quilt"
      # "rakudo"
      # "ranger"
      # "rclone"
      # "redis"
      # "rename"
      # "ruby"
      # "rust"
      # "rust-analyzer"
      # "rustscan"
      # "rustup-init"
      # "scrcpy"
      # "screenresolution"
      # "sk"
      # "socat"
      # "sops"
      # "spice-gtk"
      # "sqlc"
      # "stern"
      # "stow"
      # "stylua"
      # # "subversion"
      # # "suite-sparse"
      "syncthing"
      # "sysbench"
      # "telnet"
      # # "temporal"
      # "termshark"
      # "terraformer"
      # "tig"
      # "tilt"
      # "tinyproxy"
      # "tmux"
      # "trash-cli"
      # "tree"
      # "ttyd"
      # "typst"
      # "uchardet"
      # "viddy"
      # "vifm"
      # "wallpaper"
      # "watch"
      # "watchexec"
      # "websocat"
      # "yj"
      # "zoxide"
      # "zsh"
    ];
    onActivation.autoUpdate = false;
    # updates homebrew packages on activation,
    # can make darwin-rebuild much slower (otherwise i'd forget to do it ever though)
    casks = [
      "libreoffice"
      # "podman-desktop"
      # "podman-desktop"
      "chromium"
      "gimp"
      "kitty"
      "obsidian"
      "telegram"
      "raycast"
      # "alt-tab"
      "copyq"
      "hammerspoon"
      "krita"
      "microsoft-edge-beta"
      "utm"
      "android-platform-tools"
      "datagrip"
      # "iterm2"
      "microsoft-teams"
      "android-sdk"
      "docker"
      # "kap"
      "libreoffice"
      "mpv"
      "pycharm-ce"
      "visual-studio-code"
      "karabiner-elements"
      "macfuse"
      # "remoteviewer"
    ];
  };

  environment.etc."firefox/policies/policies.json".text = ''
{
  "policies": {
    "DontCheckDefaultBrowser": true,
    "DisablePocket": true
  }
}
'';


  # environment.etc = {
  #   "/etc/ssh/sshd_config.d/999-config.conf" = {
  #       text = ''
  #       Port 2222
  #       '';
  #   };
  # };

  environment.systemPackages = with pkgs;
    [
    ]
    ++ [
      sourcekit-lsp
      darwin.iproute2mac
      # xorg.luit
      # firefox-bin
      zigpkgs.master
      # system
      coreutils-full
      skhd
      yabai
      duti
      # pkgs.unstable.xonsh
      neovim-nightly
      unstable.alacritty
      jq
      # pkgs.unstable.rustdesk
      # pkgs.unstable.docker
      #
      pkgs.unstable.pdm
      kubectl
      # ncdu
      goconvey
      maestro
      # colima
      # pkgs.unstable.vector
    ];

  services.yabai = {
    enable = true;
    enableScriptingAddition = true;
    package = pkgs.yabai;
    config = {
      # # layout
      # layout = "bsp";
      # auto_balance = "off";
      # split_ratio = "0.50";
      # window_placement = "second_child";
      # # Gaps
      # window_gap = 18;
      # top_padding = 18;
      # bottom_padding = 52;
      # left_padding = 18;
      # right_padding = 18;
      # # shadows and borders
      # window_shadow = "float";
      # # mouse
      # mouse_follows_focus = "off";
      # focus_follows_mouse = "off";
      # mouse_modifier = "cmd";
      # mouse_action1 = "move";
      # mouse_action2 = "resize";
      # mouse_drop_action = "swap";
    };
    extraConfig = ''

      # global settings
      # yabai -m config mouse_follows_focus          off
      # yabai -m config focus_follows_mouse          off
      yabai -m config mouse_follows_focus          on
      # yabai -m config focus_follows_mouse          autoraise
      # yabai -m config focus_follows_mouse          on
      yabai -m config window_shadow                off
      yabai -m config window_border                off
      yabai -m config window_topmost               off
      yabai -m config window_opacity               off
      yabai -m config window_shadow off
      yabai -m config window_border_width          0
      yabai -m config active_window_border_color   0xff775759
      yabai -m config normal_window_border_color   0xff505050
      yabai -m config active_window_opacity        1.0
      yabai -m config normal_window_opacity        1.0
      yabai -m config split_ratio                  0.52
      yabai -m config auto_balance                 on
      # yabai -m config mouse_modifier               fn
      # yabai -m config mouse_action1                move
      # yabai -m config mouse_action2                resize

      # general space settings
      yabai -m config layout                       bsp
      yabai -m config top_padding                  0
      yabai -m config bottom_padding               0
      yabai -m config left_padding                 0
      yabai -m config right_padding                0
      yabai -m config window_gap                   0

      # yabai -m rule --add app='^CopyQ$' manage=off
      # yabai -m rule --add app='^mpv$' manage=off
    '';
  };
  services.skhd.enable = true;
  services.skhd.skhdConfig = ''
    :: default : /run/current-system/sw/bin/yabai -m config active_window_border_color 0xFF696969

    # mac
    # defaults read com.apple.spaces
    # defaults read com.apple.desktop

    # | /run/current-system/sw/bin/yabai   | bspwm   |
    # | ---     | ---     |
    # | window  | node    |
    # | space   | desktop |
    # | display | X       |

    # https://github.com/vovkasm/input-source-switcher
    # # escape -> :issw com.apple.keylayout.US
    escape -> :/opt/homebrew/bin/macism com.apple.keylayout.US; skhd -k "esc";

    #
    # FIXME
    # <esc><esc> moves cursor to right
    # escape -> :xkbswitch -e -s US
    lcmd + lctrl - 0 : open '/System/Applications/Mission Control.app';



    # lcmd + lctrl - t : alacritty -m space --focus 1;

    # application launcher
    # lcmd + lctrl - x : open '/Applications/kitty.app';
    lcmd + lctrl - x : open -a '/Applications/Alacritty.app';
    lcmd + lctrl - c : open -a 'Firefox Developer Edition';
    # lcmd + lctrl - d : open -a '/System/Applications/Dictionary.app'

    # focus & and swap node in the given direction
    lcmd + lctrl - h : /run/current-system/sw/bin/yabai -m window --focus west
    lcmd + lctrl - j : /run/current-system/sw/bin/yabai -m window --focus south
    lcmd + lctrl - k : /run/current-system/sw/bin/yabai -m window --focus north
    lcmd + lctrl - l : /run/current-system/sw/bin/yabai -m window --focus east
    lcmd + lctrl + shift - h : /run/current-system/sw/bin/yabai -m window --swap west
    lcmd + lctrl + shift - j : /run/current-system/sw/bin/yabai -m window --swap south
    lcmd + lctrl + shift - k : /run/current-system/sw/bin/yabai -m window --swap north
    lcmd + lctrl + shift - l : /run/current-system/sw/bin/yabai -m window --swap east



    # focus or send to the given desktop
    # skhd --reload
    lcmd + lctrl - 1 : /run/current-system/sw/bin/yabai -m space --focus 1;
    lcmd + lctrl - 2 : /run/current-system/sw/bin/yabai -m space --focus 2;
    lcmd + lctrl - 3 : /run/current-system/sw/bin/yabai -m space --focus 3;
    lcmd + lctrl - 4 : /run/current-system/sw/bin/yabai -m space --focus 4;
    lcmd + lctrl - 5 : /run/current-system/sw/bin/yabai -m space --focus 5;
    lcmd + lctrl - 6 : /run/current-system/sw/bin/yabai -m space --focus 6;
    lcmd + lctrl - 7 : /run/current-system/sw/bin/yabai -m space --focus 7;
    lcmd + lctrl - 8 : /run/current-system/sw/bin/yabai -m space --focus 8;
    lcmd + lctrl - 9 : /run/current-system/sw/bin/yabai -m space --focus 9;
    lcmd + lctrl + shift - 1 : /run/current-system/sw/bin/yabai -m window --space 1; /run/current-system/sw/bin/yabai -m space --focus 1;
    lcmd + lctrl + shift - 2 : /run/current-system/sw/bin/yabai -m window --space 2; /run/current-system/sw/bin/yabai -m space --focus 2;
    lcmd + lctrl + shift - 3 : /run/current-system/sw/bin/yabai -m window --space 3; /run/current-system/sw/bin/yabai -m space --focus 3;
    lcmd + lctrl + shift - 4 : /run/current-system/sw/bin/yabai -m window --space 4; /run/current-system/sw/bin/yabai -m space --focus 4;
    lcmd + lctrl + shift - 5 : /run/current-system/sw/bin/yabai -m window --space 5; /run/current-system/sw/bin/yabai -m space --focus 5;
    lcmd + lctrl + shift - 6 : /run/current-system/sw/bin/yabai -m window --space 6; /run/current-system/sw/bin/yabai -m space --focus 6;
    lcmd + lctrl + shift - 7 : /run/current-system/sw/bin/yabai -m window --space 7; /run/current-system/sw/bin/yabai -m space --focus 7;
    lcmd + lctrl + shift - 8 : /run/current-system/sw/bin/yabai -m window --space 8; /run/current-system/sw/bin/yabai -m space --focus 8;
    lcmd + lctrl + shift - 9 : /run/current-system/sw/bin/yabai -m window --space 9; /run/current-system/sw/bin/yabai -m space --focus 9;

    # focus last desktop
    # 0x33: backspace
    lcmd + lctrl - 0x33 : /run/current-system/sw/bin/yabai -m space --focus recent;

    # focus & move next/previous monitor, [ ]
    lcmd + lctrl - 0x1E : /run/current-system/sw/bin/yabai -m display --focus next;
    lcmd + lctrl - 0x21 : /run/current-system/sw/bin/yabai -m display --focus prev;
    lcmd + lctrl + shift - 0x1E : /run/current-system/sw/bin/yabai -m window --display next;
    lcmd + lctrl + shift - 0x21 : /run/current-system/sw/bin/yabai -m window --display prev;

    # focus the next/previous desktop in the current monitor, ' "
    # lcmd + lctrl - 0x27 : /run/current-system/sw/bin/yabai -m space --focus next || /run/current-system/sw/bin/yabai -m space --focus first;
    # lcmd + lctrl - 0x29 : /run/current-system/sw/bin/yabai -m space --focus prev || /run/current-system/sw/bin/yabai -m space --focus last;
    lcmd + lctrl - 0x27 : fish -c "/run/current-system/sw/bin/yabai.circular next";
    lcmd + lctrl - 0x29 : fish -c "/run/current-system/sw/bin/yabai.circular prev";
    lcmd + lctrl + shift - 0x27 : fish -c "/run/current-system/sw/bin/yabai.circular next move";
    lcmd + lctrl + shift - 0x29 : fish -c "/run/current-system/sw/bin/yabai.circular prev move";

    # focus last window (limit to current desktop)
    # lcmd + lctrl - w : /run/current-system/sw/bin/yabai -m window --focus last
    # lcmd + lctrl - 0x30 : /run/current-system/sw/bin/yabai -m window --focus recent

    # space, float / unfloat window and center on screen
    # lcmd + lctrl - 0x31 : /run/current-system/sw/bin/yabai -m window --toggle float; /run/current-system/sw/bin/yabai -m window --grid 50:50:1:2:48:47

    # focus last window (limit to current desktop)
    lcmd + lctrl - w : /run/current-system/sw/bin/yabai -m window --focus last;
    # lcmd + lctrl - q : fish -c "/run/current-system/sw/bin/yabai.circular next"; /run/current-system/sw/bin/yabai -m window --focus last;

    # kill current windows, if there's no "titlebar", kill pid directly
    lcmd + lctrl - q : /run/current-system/sw/bin/yabai -m window --close || kill $(/run/current-system/sw/bin/yabai -m query --windows --window | /run/current-system/sw/bin/jq -r .pid);
    # lcmd + lctrl - q : /run/current-system/sw/bin/yabai -m window --close;

    # balance size of windows, '='
    lcmd + lctrl - 0x18 : /run/current-system/sw/bin/yabai -m space --balance;

    # resize
    :: resizeMode @ : /run/current-system/sw/bin/yabai -m config active_window_border_color 0xFF8B0000
    lcmd + lctrl - z ; resizeMode
    resizeMode < escape ; default
    resizeMode < h : /run/current-system/sw/bin/yabai -m window --resize left:-200:0; /run/current-system/sw/bin/yabai -m window --resize right:-200:0
    resizeMode < j : /run/current-system/sw/bin/yabai -m window --resize bottom:0:200; /run/current-system/sw/bin/yabai -m window --resize top:0:200
    resizeMode < k : /run/current-system/sw/bin/yabai -m window --resize top:0:-200; /run/current-system/sw/bin/yabai -m window --resize bottom:0:-200
    resizeMode < l : /run/current-system/sw/bin/yabai -m window --resize right:200:0; /run/current-system/sw/bin/yabai -m window --resize left:200:0

    # :: appmode @ : /run/current-system/sw/bin/yabai -m config active_window_border_color 0xFF000080
    # lcmd + lctrl - x ; appmode
    # appmode < escape ; default
    # appmode < c : open /Applications/Google\ Chrome.app; skhd -k "escape"
    # appmode < a : open /Applications/Alacritty.app; skhd -k "escape"
    # appmode < k : open /Applications/KakaoTalk.app; skhd -k "escape"

    # alacritty
    # lcmd + lctrl - a : open /Applications/Alacritty.app; skhd -k "escape"
    # lcmd + lctrl - a : /Users/rok/bin/neovide; skhd -k "escape"

    # quit / restart bspwm
    # lcmd + lctrl + shift - q : brew services stop /run/current-system/sw/bin/yabai
    # lcmd + lctrl + shift - r : brew services restart /run/current-system/sw/bin/yabai


    # # |, sleep
    # lcmd + lctrl + shift - 0x2A : pmset displaysleepnow

    # esc, mission control
    lcmd + lctrl - escape : open -a '/System/Applications/Mission Control.app';

    # rotate tree
    lcmd + lctrl - r : /run/current-system/sw/bin/yabai -m space --rotate 90;

    # lcmd + lctrl - f : /run/current-system/sw/bin/yabai -m window --toggle native-fullscreen
    lcmd + lctrl - f : /run/current-system/sw/bin/yabai -m window --toggle zoom-fullscreen

    # toggle window native fullscreen
    # lcmd + lctrl + shift - f : /run/current-system/sw/bin/yabai -m window --toggle native-fullscreen;

    # # make floating window fill screen
    # shift + alt - up     : /run/current-system/sw/bin/yabai -m window --grid 1:1:0:0:1:1

    # # make floating window fill left-half of screen
    # shift + alt - left   : /run/current-system/sw/bin/yabai -m window --grid 1:2:0:0:1:1

    # # make floating window fill right-half of screen
    # shift + alt - right  : /run/current-system/sw/bin/yabai -m window --grid 1:2:1:0:1:1
  '';

  # Make sure the nix daemon always runs
  # services.nix-daemon.enable = true;

  nix.package = pkgs.nix;

  programs.fish.enable = true;
  programs.zsh.enable = true;
  programs.bash.enable = true;

  system = {
    stateVersion = 4;

    defaults = {
      LaunchServices = {
        LSQuarantine = false;
      };

      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;

        # 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 2;

        # 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 15;

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
      };

      dock = {
        autohide = true;
        show-recents = false;
        launchanim = true;
        orientation = "bottom";
        tilesize = 48;
      };

      finder = {
        _FXShowPosixPathInTitle = true;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  launchd.daemons.pueued = {
    script = ''
      /run/current-system/sw/bin/pueued
    '';
    serviceConfig.RunAtLoad = true;
    serviceConfig.UserName = ''kyungrok.chung'';
    serviceConfig.KeepAlive = true;
  };

  # launchd.daemons.colima = {
  #   command = ''
  #     /usr/bin/caffeinate -d
  #   '';
  #   serviceConfig.RunAtLoad = true;
  #   serviceConfig.KeepAlive = false;
  #   # serviceConfig.StandardErrorPath = "/Users/kyungrok.chung/tmp/enableSSH.stdout.log";
  #   # serviceConfig.StandardOutPath = "/Users/kyungrok.chung/tmp/enableSSH.stderr.log";
  # };

  launchd.daemons.caffeinate = {
    command = ''
      /usr/bin/caffeinate -d
    '';
    serviceConfig.RunAtLoad = true;
    serviceConfig.KeepAlive = false;
    # serviceConfig.StandardErrorPath = "/Users/kyungrok.chung/tmp/enableSSH.stdout.log";
    # serviceConfig.StandardOutPath = "/Users/kyungrok.chung/tmp/enableSSH.stderr.log";
  };

  system.activationScripts.extraActivation.text = ''
    # # Install Homebrew
    #
    # # Install Rosetta
    # stat /Library/Apple/usr/share/rosetta/rosetta 2>&1 > /dev/null || softwareupdate --install-rosetta

    # Ensure SSH is on.
    systemsetup -setremotelogin on 2>&1 > /dev/null || true

    # Disable lid close sleep
    # sudo pmset -b disablesleep 1 || true
  '';

  # launchd.daemons.helloworld = {
  #   command = "${pkgs.bash} -c 'echo hello >> /Users/kyungrok.chung/tmp/debug'";
  #   serviceConfig.RunAtLoad = true;
  #   # serviceConfig.StandardErrorPath = "/var/log/prometheus-node-exporter.log";
  #   # serviceConfig.StandardOutPath = "/var/log/prometheus-node-exporter.log";
  # };
}
