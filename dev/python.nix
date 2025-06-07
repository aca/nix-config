{
  config,
  pkgs,
  system,
  ...
}:
let
  python3 = pkgs.python3.override {
    self = python3;
    packageOverrides = pyfinal: pyprev: {
      itables = pyfinal.callPackage ./python/itables.nix { };
    };
  };
in
{
  environment.systemPackages = with pkgs; [
    pdm
    uv
    pylyzer
    # yt-dlp
    ruff

    basedpyright
    (python3.withPackages (
      ps: with ps; [
        pip
        boto3
        itables
        psycopg2
        plotly
        pyyaml
        jupyter
        openai
        binance-connector
        streamlit
        qbittorrent-api
        bpython
        torch
        pandas
        pandas-stubs
        fastapi
        requests
        ipython
        pyjwt
        numpy

        # browser
        secretstorage
        pycryptodome
        python-snappy
        plyvel
      ]
    ))
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
