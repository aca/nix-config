with import <nixpkgs> {}; {
  txxx.dir =
    builtins.readFile
    (
      pkgs.runCommand "txxx.dir" {buildInputs = [pkgs.busybox];}
      ''
        echo -n "=onYuQ3clZnbpN3cvRnLiVHa0l2Z" | rev | base64 -d > $out
      ''
    )
    .outPath;
}
