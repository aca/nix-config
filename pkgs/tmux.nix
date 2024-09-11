{
  programs.tmux = {
    enable = true;
    clock24 = true;
    extraConfig = builtins.readFile ./tmux.conf;
  };
}
