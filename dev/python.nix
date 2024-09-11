{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    pkgs.pylyzer
    (
      pkgs.python3.withPackages (ps:
        with ps; [
          requests
          pip
          boto3
          pyyaml
          yt-dlp
          xonsh
          frogmouth
          pandas
          numpy
          pipx
        ])
    )
  ];
}
