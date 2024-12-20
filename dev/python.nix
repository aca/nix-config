{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    pdm
    uv
    pylyzer
    yt-dlp

    basedpyright
    (python3.withPackages (ps:
      with ps; [
        boto3
        pyyaml
        bpython
        torch
        pandas
        plotly
        fastapi
        requests
        ipython
        numpy
      ]))
    #   python3.withPackages
    #   (
    #     ps:
    #       with ps; [
    #         requests
    #         boto3
    #         pyyaml
    #         virtualenv
    #         yt-dlp
    #         ptpython
    #         matplotlib
    #         pandas
    #
    #         # linux dbus related
    #         dbus-python
    #         pygobject3
    #
    #         requests
    #         pip
    #         boto3
    #         pyyaml
    #         yt-dlp
    #         xonsh
    #         frogmouth
    #         pandas
    #         numpy
    #         pipx
    #         # pandas
    #         # numpy
    #       ]
    #   )
  ];
}
