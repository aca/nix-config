{
  config,
  pkgs,
  lib,
  ...
}:
let
  path = lib.strings.concatStringsSep ":" [
    # "$HOME/.venv/bin"
    "$HOME/src/codeberg.org/aca/nix-config/pkgs/scripts"
    "$HOME/src/github.com/aca/nix-config/pkgs/scripts"
    "$HOME/src/go.googlesource.com/go/bin"
    "$HOME/bin"
    "$HOME/.bun/bin"
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/src/git.internal/xxx/bin"
  ];
in
{
  environment.variables =
    {
      # "VTE_VERSION" = "9999";
      # "XDG_DATA_DIRS"="$XDG_DATA_DIRS:/home/rok/src/github.com/aca/dotfiles";
      "GOTOOLCHAIN" = "local"; # gopls ignore go version
      "NTFY_BASE_URL" = "http://archive-0:2555";
      "NIXPKGS_ALLOW_UNFREE" = "1";

      # "LANG" = "en_US.UTF-8";
      # "LANGUAGE" = "en_US.UTF-8";
      # "LC_ALL" = "en_US.UTF-8";
      # "LANG" = "en_US.UTF-8";
      # "LANGUAGE" = "en_US.UTF-8";
      # "LC_ALL" = "en_US.UTF-8";
      "LC_ALL" = "en_US.UTF-8";

      "COLORTERM" = "truecolor";
      "VISUAL" = "nvim";
      "EDITOR" = "nvim";
      "MANPAGER" = "nvim +Man!";
      "MANWIDTH" = "90";

      "GOPATH" = "$HOME";
      "GOPROXY" = "direct";

      "NODE_OPTIONS" =
        "--experimental-fetch --experimental-top-level-await --experimental-modules --no-warnings";
      "NPM_CONFIG_GLOBALCONFIG" = "~/.npmrc.global";
      "DENO_NO_UPDATE_CHECK" = "1";

      "GHQ_ROOT" = "$HOME/src";
      "RIPGREP_CONFIG_PATH" = "$HOME/.config/ripgrep/rc";
      "FZF_DEFAULT_COMMAND" = "${pkgs.fd}/bin/fd -L --hidden --type f --type symlink";
      # --prompt '» '
      "FZF_DEFAULT_OPTS" =
        "--min-height 15 --reverse --color gutter:-1 --info=inline --no-scrollbar --no-separator --cycle -m --bind ctrl-a:toggle-all --bind ctrl-n:down --bind ctrl-d:page-down --bind ctrl-u:page-up --bind ctrl-p:up --bind ctrl-w:toggle-preview";
      "FZF_ALT_C_COMMAND" = "${pkgs.fd}/bin/fd --hidden --type d --max-depth 10 --no-ignore";
      "BROWSER" = "chromium";
    }
    // (
      if pkgs.stdenv.isDarwin then
        {
          PATH = path + ":/opt/homebrew/bin:$PATH";
        }
      else
        {
          PATH = path;
          # "GLFW_IM_MODULE" = "fcitx";
          # GTK_IM_MODULE = "fcitx";
          # XMODIFIERS = "@im=fcitx";
          # SDL_IM_MODULE = "fcitx";
          # QT_IM_MODULE = "fcitx";

          # GLFW_IM_MODULE = "kime";
          # GTK_IM_MODULE = "kime";
          # XMODIFIERS = "@im=kime";
          # SDL_IM_MODULE = "kime";
          # QT_IM_MODULE = "kime";
        }
    );
}
#     # # tool:libvirt
#     # + ''
#     #   export LIBVIRT_DEFAULT_URI="qemu:///system"
#     #   export VIRSH_DEFAULT_CONNECT_URI="qemu:///system"
#     # ''
#   # environment.extraInit =
#     # lang:python
#     # + ''
#     #   export PYTHONSTARTUP pythonstartup
#     # ''
#     # tool:fzf
#     # export FZF_DEFAULT_OPTS='--min-height 15 --reverse --color "gutter:-1" --info=inline --no-scrollbar --no-separator --cycle -m --bind ctrl-a:toggle-all --bind ctrl-n:down --bind ctrl-d:page-down --bind ctrl-u:page-up --bind ctrl-p:up --bind ctrl-w:toggle-preview --prompt "» "'
#     ''
#       # FZF
#     ''
#     # misc
#     # export NCDU_SHELL=elvish
#     # export DOCKER_BUILDKIT=1
#     + ''
#     ''
#     # + ''
#     #   # https://github.com/MDeiml/tree-sitter-markdown
#     #   # export EXTENSION_WIKI_LINK=true
#     #   # export EXTENSION_TAGS=true
#     # ''
#     + (
#       if pkgs.stdenv.isDarwin
#       # use system clang instead of nix for cgo build
#       then ''
#         export CC=/usr/bin/clang
#       ''
#       # IM
#       else ''
#         export GLFW_IM_MODULE=fcitx
#         export GTK_IM_MODULE=fcitx
#         export XMODIFIERS=@im=fcitx
#         export SDL_IM_MODULE=fcitx
#         export QT_IM_MODULE=fcitx
#       ''
#     )
#     + (
#       if pkgs.stdenv.isDarwin
#       then ''
#         export PATH=$HOME/bin/x:$HOME/bin:$HOME/.cargo/bin:$PATH
#       ''
#       # darwin, /run/current-system/sw/bin # sudo issue, /run/wrappers/bin/sudo should be run
#       else ''
#         export PATH=$HOME/bin/x:$HOME/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:/opt/homebrew/bin:$HOME/.cargo/bin:$PATH
#       ''
#     );
# }
