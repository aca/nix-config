# https://nixos.org/guides/nix-pills/
{
  config,
  pkgs,
  options,
  ...
}:
let
  hostName = "txxx";
in
{
  nix.package = pkgs.nix;
  nix.enable = false;

  nix.settings.experimental-features = "nix-command flakes";
  # nix.settings.trusted-users = ["root" "rok"];

  # networking.hosts = {
  #   "100.127.31.30" = ["git.internal"];
  # };

  imports = [
    ./env.nix
    ./pkgs/scripts.nix
    ./pkgs/scripts.darwin.nix

    ./pkgs/tmux/tmux.nix
    ./dev/nix.nix
    ./dev/zig.nix
    ./dev/js.nix
    ./dev/data.nix
    ./dev/lua.nix
    ./dev/go.nix
    ./dev/c.nix
    ./dev/rust.nix
    ./dev/default_ssh.nix
    ./dev/default.nix
  ];

  environment.systemPath = [ "/opt/homebrew/bin" ];
  environment.pathsToLink = [ "/Application" ];

  # environment.variables = rec {
  #   LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [pkgs.oracle-instantclient];
  # };

  system.primaryUser = "kyungrok.chung";

  homebrew = {
    enable = true;
    caskArgs.no_quarantine = false;
    global.brewfile = true;
    # `brew leaves` to show installed
    # `brew list --cask`
    taps = [
      # "laishulu/macism"
      # "aca/tap"
      # "zegervdv/zathura"
      # "homebrew/cask-versions" # wezterm
      # "encoredev/tap/encore"
      # "chipmk/tap/docker-mac-net-connect"
    ];
    brews = [
      # "laishulu/macism/macism"
      # "zegervdv/zathura/zathura-pdf-poppler"
      "aca/tap/agec"
      # "telnet"
      # "mas"
      # "mupdf"
      # "syncthing"
    ];
    # updates homebrew packages on activation,
    onActivation.autoUpdate = false;
    casks = [
      # "alfred"
      "karabiner-elements"
      "chromium"
      # "vmware-fusion"
      "jordanbaird-ice"
      # "google-chrome@canary"
      # "podman-desktop"
      # "podman-desktop"
      # "chromium"
      # "kitty"
      # "obsidian"
      # "telegram"
      # "raycast"
      # "alt-tab"
      # "copyq"
      # "hammerspoon"
      # "krita"
      # "microsoft-edge-beta"
      # "utm"
      # "android-platform-tools"
      "datagrip"
      # # "iterm2"
      # "microsoft-teams"
      # "android-sdk"
      # "docker"
      # "kap"
      "libreoffice"
      # "mpv"
      # "pycharm-ce"
      # "visual-studio-code"
      # "vivaldi"
      # "karabiner-elements"
      # "macfuse"
      # "remoteviewer"
    ];
  };

  # security.sudo.extraConfig = ''
  #   kyungrok.chung ALL=(ALL) NOPASSWD: ALL
  # '';

  #   environment.etc."firefox/policies/policies.json".text = ''
  # {
  #   "policies": {
  #     "DontCheckDefaultBrowser": true,
  #     "DisablePocket": true
  #   }
  # }
  # '';
  #

  # environment.etc = {
  #   "/etc/ssh/sshd_config.d/999-config.conf" = {
  #       text = ''
  #       Port 2222
  #       '';
  #   };
  # };

  # services.dnsmasq = {
  #   enable = true;
  #   bind = "0.0.0.0"
  #   # settings = {
  #   #   cache-size = 10000;
  #   #   clear-on-reload = true;
  #   #   min-cache-ttl = 3600;
  #   #   log-queries = true;
  #   #   log-dhcp = true;
  #   #   server = [
  #   #     "8.8.8.8"
  #   #   ];
  #   # };
  # };

  environment.systemPackages =
    with pkgs;
    [
    ]
    ++ [
      docker-client
      tyson
      age
      luit
      sourcekit-lsp
      iproute2mac
      coreutils-full
      duti
      elvish
      alacritty
      jq
      kubectl
      ncdu
      trash-cli
      headscale
      tailscale
      mpv
      # ncdu
      # goconvey
      # maestro
      # colima
      # pkgs.unstable.vector
      # pkgs.unstable.rustdesk
      # pkgs.unstable.docker
      # iosevka-term
      # raycast
      # pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
      # pkgs.darwin.apple_sdk.frameworks.CoreFoundation
      # pkgs.darwin.apple_sdk.frameworks.Security
    ];

  services.skhd.enable = true;
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
      # yabai -m config external_bar all:30:0
      yabai -m config external_bar all:0:0

      # general space settings
      yabai -m config layout                       bsp
      yabai -m config top_padding                  0
      yabai -m config bottom_padding               0
      yabai -m config left_padding                 0
      yabai -m config right_padding                0
      yabai -m config window_gap                   0

      # yabai -m rule --add app='^CopyQ$' manage=off
      # yabai -m rule --add app='^mpv$' manage=off

      yabai -m signal --add event=dock_did_restart action="sudo /run/current-system/sw/bin/yabai --load-sa"
      # yabai -m rule --add app="^(System Settings|System Information|Activity Monitor|FaceTime|Screen Sharing|Calculator|Stickies|TinkerTool|Progressive Downloader|Transmission|Airflow)$" manage=off
      sudo yabai --load-sa

      # yabai -m signal --add event=window_focused action="/opt/homebrew/bin/sketchybar --trigger window_focus"
      # yabai -m signal --add event=window_created action="/opt/homebrew/bin/sketchybar --trigger windows_on_spaces"
      # yabai -m signal --add event=window_destroyed action="/opt/homebrew/bin/sketchybar --trigger windows_on_spaces"

    '';
  };
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
    # escape -> :/opt/homebrew/bin/macism com.apple.keylayout.US; skhd -k "esc";

    #
    # FIXME
    # <esc><esc> moves cursor to right
    # escape -> :xkbswitch -e -s US
    lcmd + lctrl + lalt - 0 : open '/System/Applications/Mission Control.app';



    # lcmd + lctrl + lalt - t : alacritty -m space --focus 1;

    # application launcher
    lcmd + lctrl + lalt - y : /run/current-system/sw/bin/work.antisleep
    lcmd + lctrl + lalt + shift - y : /usr/bin/pkill -f work.antisleep
    lcmd + lctrl + lalt - x : open /Applications/Ghostty.app;
    lcmd + lctrl + lalt - 0x32 : open /Applications/Ghostty.app;
    # lcmd + lctrl + lalt - c : open -a 'Firefox Developer Edition';
    # lcmd + lctrl + lalt - c : /Applications/Vivaldi.app/Contents/MacOS/Vivaldi --remote-debugging-port=9222;
    lcmd + lctrl + lalt - c : open -a 'Vivaldi' --args --remote-debugging-port=9222 --remote-debugging-host=0.0.0.0;
    # lcmd + lctrl + lalt - d : open -a '/System/Applications/Dictionary.app'

    # focus & and swap node in the given direction
    lcmd + lctrl + lalt - h : /run/current-system/sw/bin/yabai -m window --focus west
    lcmd + lctrl + lalt - j : /run/current-system/sw/bin/yabai -m window --focus south
    lcmd + lctrl + lalt - k : /run/current-system/sw/bin/yabai -m window --focus north
    lcmd + lctrl + lalt - l : /run/current-system/sw/bin/yabai -m window --focus east
    lcmd + lctrl + lalt + shift - h : /run/current-system/sw/bin/yabai -m window --swap west
    lcmd + lctrl + lalt + shift - j : /run/current-system/sw/bin/yabai -m window --swap south
    lcmd + lctrl + lalt + shift - k : /run/current-system/sw/bin/yabai -m window --swap north
    lcmd + lctrl + lalt + shift - l : /run/current-system/sw/bin/yabai -m window --swap east



    # focus or send to the given desktop
    # skhd --reload
    lcmd + lctrl + lalt - 1 : /run/current-system/sw/bin/yabai -m space --focus 1;
    lcmd + lctrl + lalt - 2 : /run/current-system/sw/bin/yabai -m space --focus 2;
    lcmd + lctrl + lalt - 3 : /run/current-system/sw/bin/yabai -m space --focus 3;
    lcmd + lctrl + lalt - 4 : /run/current-system/sw/bin/yabai -m space --focus 4;
    lcmd + lctrl + lalt - 5 : /run/current-system/sw/bin/yabai -m space --focus 5;
    lcmd + lctrl + lalt - 6 : /run/current-system/sw/bin/yabai -m space --focus 6;
    lcmd + lctrl + lalt - 7 : /run/current-system/sw/bin/yabai -m space --focus 7;
    lcmd + lctrl + lalt - 8 : /run/current-system/sw/bin/yabai -m space --focus 8;
    lcmd + lctrl + lalt - 9 : /run/current-system/sw/bin/yabai -m space --focus 9;
    lcmd + lctrl + lalt + shift - 1 : /run/current-system/sw/bin/yabai -m window --space 1; /run/current-system/sw/bin/yabai -m space --focus 1;
    lcmd + lctrl + lalt + shift - 2 : /run/current-system/sw/bin/yabai -m window --space 2; /run/current-system/sw/bin/yabai -m space --focus 2;
    lcmd + lctrl + lalt + shift - 3 : /run/current-system/sw/bin/yabai -m window --space 3; /run/current-system/sw/bin/yabai -m space --focus 3;
    lcmd + lctrl + lalt + shift - 4 : /run/current-system/sw/bin/yabai -m window --space 4; /run/current-system/sw/bin/yabai -m space --focus 4;
    lcmd + lctrl + lalt + shift - 5 : /run/current-system/sw/bin/yabai -m window --space 5; /run/current-system/sw/bin/yabai -m space --focus 5;
    lcmd + lctrl + lalt + shift - 6 : /run/current-system/sw/bin/yabai -m window --space 6; /run/current-system/sw/bin/yabai -m space --focus 6;
    lcmd + lctrl + lalt + shift - 7 : /run/current-system/sw/bin/yabai -m window --space 7; /run/current-system/sw/bin/yabai -m space --focus 7;
    lcmd + lctrl + lalt + shift - 8 : /run/current-system/sw/bin/yabai -m window --space 8; /run/current-system/sw/bin/yabai -m space --focus 8;
    lcmd + lctrl + lalt + shift - 9 : /run/current-system/sw/bin/yabai -m window --space 9; /run/current-system/sw/bin/yabai -m space --focus 9;

    # focus last desktop
    # 0x33: backspace
    lcmd + lctrl + lalt - 0x33 : /run/current-system/sw/bin/yabai -m space --focus recent;
    lcmd + lctrl + lalt - tab: /run/current-system/sw/bin/yabai -m space --focus recent;

    # focus & move next/previous monitor, [ ]
    # lcmd + lctrl + lalt - 0x1E : /run/current-system/sw/bin/yabai -m display --focus next || /run/current-system/sw/bin/yabai -m display --focus first;
    # lcmd + lctrl + lalt - 0x21 : /run/current-system/sw/bin/yabai -m display --focus prev || /run/current-system/sw/bin/yabai -m display --focus last;
    lcmd + lctrl + lalt + shift - 0x1E : /run/current-system/sw/bin/yabai -m window --display next;
    lcmd + lctrl + lalt + shift - 0x21 : /run/current-system/sw/bin/yabai -m window --display prev;
    lcmd + lctrl + lalt - 0x1E : /run/current-system/sw/bin/yabai -m display --focus next || /run/current-system/sw/bin/yabai -m display --focus first || /run/current-system/sw/bin/yabai -m space --focus next || /run/current-system/sw/bin/yabai -m space --focus first;
    lcmd + lctrl + lalt - 0x21 : /run/current-system/sw/bin/yabai -m display --focus prev || /run/current-system/sw/bin/yabai -m display --focus last || /run/current-system/sw/bin/yabai -m space --focus prev || /run/current-system/sw/bin/yabai -m space --focus last;

    # focus the next/previous desktop in the current monitor, ' "
    lcmd + lctrl + lalt - 0x27 : /run/current-system/sw/bin/yabai -m space --focus next || /run/current-system/sw/bin/yabai -m space --focus first;
    lcmd + lctrl + lalt - 0x29 : /run/current-system/sw/bin/yabai -m space --focus prev || /run/current-system/sw/bin/yabai -m space --focus last;
    # lcmd + lctrl + lalt - 0x27 : fish -c "/run/current-system/sw/bin/yabai.circular next";
    # lcmd + lctrl + lalt - 0x29 : fish -c "/run/current-system/sw/bin/yabai.circular prev";
    lcmd + lctrl + lalt + shift - 0x27 : fish -c "/run/current-system/sw/bin/yabai.circular next move";
    lcmd + lctrl + lalt + shift - 0x29 : fish -c "/run/current-system/sw/bin/yabai.circular prev move";

    # focus last window (limit to current desktop)
    # lcmd + lctrl + lalt - w : /run/current-system/sw/bin/yabai -m window --focus last
    # lcmd + lctrl + lalt - 0x30 : /run/current-system/sw/bin/yabai -m window --focus recent

    # space, float / unfloat window and center on screen
    # lcmd + lctrl + lalt - 0x31 : /run/current-system/sw/bin/yabai -m window --toggle float; /run/current-system/sw/bin/yabai -m window --grid 50:50:1:2:48:47

    # focus last window (limit to current desktop)
    lcmd + lctrl + lalt - w : /run/current-system/sw/bin/yabai -m window --focus last;
    # lcmd + lctrl + lalt - q : fish -c "/run/current-system/sw/bin/yabai.circular next"; /run/current-system/sw/bin/yabai -m window --focus last;

    # kill current windows, if there's no "titlebar", kill pid directly
    # lcmd + lctrl + lalt - q : /run/current-system/sw/bin/yabai -m window --close || kill $(/run/current-system/sw/bin/yabai -m query --windows --window | /run/current-system/sw/bin/jq -r .pid);
    lcmd + lctrl + lalt - q : /run/current-system/sw/bin/yabai_kill_last;
    # lcmd + lctrl + lalt - q : /run/current-system/sw/bin/yabai -m window --close;

    # balance size of windows, '='
    lcmd + lctrl + lalt - 0x18 : /run/current-system/sw/bin/yabai -m space --balance;

    # resize
    :: resizeMode @ : /run/current-system/sw/bin/yabai -m config active_window_border_color 0xFF8B0000
    lcmd + lctrl + lalt - z ; resizeMode
    resizeMode < escape ; default
    resizeMode < h : /run/current-system/sw/bin/yabai -m window --resize left:-200:0; /run/current-system/sw/bin/yabai -m window --resize right:-200:0
    resizeMode < j : /run/current-system/sw/bin/yabai -m window --resize bottom:0:200; /run/current-system/sw/bin/yabai -m window --resize top:0:200
    resizeMode < k : /run/current-system/sw/bin/yabai -m window --resize top:0:-200; /run/current-system/sw/bin/yabai -m window --resize bottom:0:-200
    resizeMode < l : /run/current-system/sw/bin/yabai -m window --resize right:200:0; /run/current-system/sw/bin/yabai -m window --resize left:200:0

    # :: appmode @ : /run/current-system/sw/bin/yabai -m config active_window_border_color 0xFF000080
    # lcmd + lctrl + lalt - x ; appmode
    # appmode < escape ; default
    # appmode < c : open /Applications/Google\ Chrome.app; skhd -k "escape"
    # appmode < a : open /Applications/Alacritty.app; skhd -k "escape"
    # appmode < k : open /Applications/KakaoTalk.app; skhd -k "escape"

    # terminal (backtick)
    # lcmd + lctrl + lalt - c : open ${pkgs.firefox-devedition-bin};
    # lcmd + lctrl + lalt - c : /Users/rok/bin/neovide; skhd -k "escape"

    # quit / restart bspwm
    # lcmd + lctrl + lalt + shift - q : brew services stop /run/current-system/sw/bin/yabai
    # lcmd + lctrl + lalt + shift - r : brew services restart /run/current-system/sw/bin/yabai


    # # |, sleep
    lcmd + lctrl + lalt + shift - 0x2A : pmset displaysleepnow
    lcmd + lctrl + lalt + shift - escape : pmset displaysleepnow

    # esc, mission control
    lcmd + lctrl + lalt - escape : open -a '/System/Applications/Mission Control.app';

    # rotate tree
    lcmd + lctrl + lalt - r : /run/current-system/sw/bin/yabai -m space --rotate 90;

    # lcmd + lctrl + lalt - f : /run/current-system/sw/bin/yabai -m window --toggle native-fullscreen
    lcmd + lctrl + lalt - f : /run/current-system/sw/bin/yabai -m window --toggle zoom-fullscreen

    # toggle window native fullscreen
    # lcmd + lctrl + lalt + shift - f : /run/current-system/sw/bin/yabai -m window --toggle native-fullscreen;

    # # make floating window fill screen
    # shift + alt - up     : /run/current-system/sw/bin/yabai -m window --grid 1:1:0:0:1:1

    # # make floating window fill left-half of screen
    # shift + alt - left   : /run/current-system/sw/bin/yabai -m window --grid 1:2:0:0:1:1

    # # make floating window fill right-half of screen
    # shift + alt - right  : /run/current-system/sw/bin/yabai -m window --grid 1:2:1:0:1:1
  '';

  # Make sure the nix daemon always runs
  # services.nix-daemon.enable = true;

  programs.fish.enable = true;
  programs.zsh.enable = true;
  programs.bash.enable = true;

  # sudo defaults write /Library/Preferences/FeatureFlags/Domain/UIKit.plist emoji_enhancements -dict-add Enabled -bool NO
  system = {
    stateVersion = 4;

    defaults = {
      LaunchServices = {
        LSQuarantine = false;
      };

      CustomUserPreferences = {
        # "/Library/Preferences/FeatureFlags/Domain/UIKit.plist" = {
        #   "emoji_enhancements" = {
        #     "Enabled" = false;
        #   };
        # };
        # disable ctrl + command + space
        # defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 '{enabled = 0;}'
        # defaults read com.apple.symbolichotkeys
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            "175" = {
              enabled = false;
              value = {
                parameters = [
                  65535
                  65535
                  0
                ];
                type = "standard";
              };
            };
            "184" = {
              enabled = true;
              value = {
                parameters = [
                  112
                  35
                  1966080
                ];
                type = "standard";
              };
            };
            "190" = {
              enabled = false;
              value = {
                parameters = [
                  113
                  12
                  8388608
                ];
                type = "standard";
              };
            };
            "222" = {
              enabled = false;
              value = {
                parameters = [
                  65535
                  65535
                  0
                ];
                type = "standard";
              };
            };
            "31" = {
              enabled = true;
              value = {
                parameters = [
                  112
                  35
                  1835008
                ];
                type = "standard";
              };
            };
            "32" = {
              enabled = false;
              value = {
                parameters = [
                  65535
                  126
                  8650752
                ];
                type = "standard";
              };
            };
            "33" = {
              enabled = false;
              value = {
                parameters = [
                  65535
                  125
                  8650752
                ];
                type = "standard";
              };
            };
            "36" = {
              enabled = false;
              value = {
                parameters = [
                  65535
                  103
                  8388608
                ];
                type = "standard";
              };
            };
            "52" = {
              enabled = true;
              value = {
                parameters = [
                  100
                  2
                  1835008
                ];
                type = "standard";
              };
            };
            "53" = {
              enabled = true;
              value = {
                parameters = [
                  65535
                  107
                  8388608
                ];
                type = "standard";
              };
            };
            "55" = {
              enabled = true;
              value = {
                parameters = [
                  65535
                  107
                  8912896
                ];
                type = "standard";
              };
            };
            "61" = {
              enabled = true;
              value = {
                parameters = [
                  32
                  49
                  1835008
                ];
                type = "standard";
              };
            };
            "64" = {
              enabled = true;
              value = {
                parameters = [
                  65535
                  36
                  1835008
                ];
                type = "standard";
              };
            };
            "60" = {
              enabled = false;
              value = {
                parameters = [
                  65535
                  36
                  1835008
                ];
                type = "standard";
              };
            };
            "65" = {
              enabled = false;
              value = {
                parameters = [
                  32
                  49
                  1572864
                ];
                type = "standard";
              };
            };
          };
        };

        "com.apple.screensaver" = {
          # Require password immediately after sleep or screen saver begins
          askForPassword = 1;
          askForPasswordDelay = 0;
          idleTime = 0;
        };

        "com.apple.screencapture" = {
          location = "~/";
          type = "png";
        };

        # Prevent Photos from opening automatically when devices are plugged in
        "com.apple.ImageCapture".disableHotPlug = true;
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
      # userKeyMapping = [
      #   {
      #     HIDKeyboardModifierMappingDst = 30064771296;
      #     HIDKeyboardModifierMappingSrc = 30064771129;
      #   }
      # ];
    };
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    ibm-plex
    nerd-fonts.iosevka-term-slab
    nerd-fonts.sauce-code-pro
    nerd-fonts.blex-mono
  ];

  # launchd.daemons.tailscaled = {
  #   script = ''
  #     /run/current-system/sw/bin/tailscaled --tun=userspace-networking --socks5-server=0.0.0.0:1081
  #   '';
  #   serviceConfig.RunAtLoad = true;
  #   serviceConfig.UserName = "kyungrok.chung";
  #   serviceConfig.KeepAlive = true;
  # };

  # launchd.daemons.oracle = {
  #   script = ''
  #     /run/current-system/sw/bin/socat -v TCP-LISTEN:1521,fork TCP:100.85.204.31:1521
  #   '';
  #   serviceConfig.RunAtLoad = true;
  #   serviceConfig.UserName = ''kyungrok.chung'';
  #   serviceConfig.KeepAlive = true;
  # };

  launchd.daemons.caffeinate = {
    command = ''
      /usr/bin/caffeinate -d
    '';
    serviceConfig.RunAtLoad = true;
    serviceConfig.KeepAlive = false;
  };

  # system.activationScripts.extraActivation.text = ''
  #   # # Install Homebrew
  #   #
  #   # # Install Rosetta
  #   # stat /Library/Apple/usr/share/rosetta/rosetta 2>&1 > /dev/null || softwareupdate --install-rosetta
  #
  #   # Ensure SSH is on.
  #   # systemsetup -setremotelogin off
  #   # systemsetup -setremotelogin on
  #
  #   # Disable lid close sleep
  #   # sudo pmset -b disablesleep 1 || true
  # '';

  # launchd.daemons.helloworld = {
  #   command = "${pkgs.bash} -c 'echo hello >> /Users/kyungrok.chung/tmp/debug'";
  #   serviceConfig.RunAtLoad = true;
  #   # serviceConfig.StandardErrorPath = "/var/log/prometheus-node-exporter.log";
  #   # serviceConfig.StandardOutPath = "/var/log/prometheus-node-exporter.log";
  # };
  # https://github.com/NixOS/nix/issues/7055#issuecomment-1250166187
}
