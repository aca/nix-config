{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    (
      pkgs.unstable.python3.withPackages (ps:
        with ps; [
          requests
          pip
          boto3
          pyyaml
          yt-dlp
          frogmouth
          pandas
          numpy
        ])
    )
  ];
}
