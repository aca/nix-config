{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
in {
  home.file.".local/share/elvish/lib/github.com/aca/elvish-utils".source = inputs.elvish-utils.outPath;
  home.file.".local/share/elvish/lib/github.com/xiaq/edit.elv".source = inputs.elvish-edit-elv.outPath;
  home.file.".config/elvish/rc.elv".text =
    ''
      use github.com/xiaq/edit.elv/smart-matcher; smart-matcher:apply
    ''
    + ''
      use github.com/aca/elvish-utils/fish-completer
      use github.com/aca/elvish-utils/fish-completer-apply-all
      fish-completer:apply just
    ''
    + ''
      use str
      use re
    ''
    + (builtins.readFile ./rc.elv)
    + (builtins.readFile ./bind.elv)
    + (builtins.readFile ./interactive.elv)
    + (builtins.readFile ./prompt.elv)
    # wrappers
    # fn cp {|@a| e:advcp -gv $@a}
    # fn mv {|@a| e:advmv -gv $@a}
    + ''
      # fn rm {|@a| ${pkgs.rmtrash}/bin/rmtrash $@a}
      fn cp {|@a| e:cp -v $@a}
      fn mv {|@a| e:mv -v $@a}
      fn grep {|@a| ${pkgs.coreutils}/bin/stdbuf -i0 -o0 -e0 ${pkgs.gnugrep}/bin/grep $@a}
      fn f {|@a| cd (${pkgs.vifm}/bin/vifm $@a --choose-dir -)}
    ''
    + (
      if pkgs.stdenv.isDarwin
      then ''
        fn l {|@a| ${pkgs.coreutils}/bin/ls -1G $@a }
        fn ll {|@a| ${pkgs.coreutils}/bin/ls -1aG $@a }
      ''
      else ''
        fn l {|@a| ${pkgs.coreutils}/bin/ls -1 --color=auto $@a }
        fn ll {|@a| ${pkgs.coreutils}/bin/ls -1al --color=auto $@a }
      ''
    )
    # + ''
    #   set @edit:before-readline = $@edit:before-readline {
    #       try {
    #           var m = [(${pkgs.direnv}/bin/direnv export elvish 2>/dev/null | from-json)]
    #           if (> (count $m) 0) {
    #               set m = (all $m)
    #               keys $m | each { |k|
    #                   if $m[$k] {
    #                       set-env $k $m[$k]
    #                   } else {
    #                       unset-env $k
    #                   }
    #               }
    #           }
    #       } catch e {
    #           nop
    #           # echo $e
    #       }
    #   }
    # ''
    # cloudflare warp proxy
    # fn proxyon {
    #     set-env http_proxy "http://localhost:40000/"
    #     set-env https_proxy "http://localhost:40000/"
    #     set-env no_proxy "127.0.0.1,localhost,192.168.0.0/16"
    # }
    #
    # fn proxyoff {
    #     unset-env http_proxy
    #     unset-env https_proxy
    #     unset-env no_proxy
    # }
    + (builtins.readFile ./ghostty.elv);
}
