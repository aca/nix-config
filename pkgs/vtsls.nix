# # # https://github.com/NixOS/nixpkgs/issues/231513
# # # https://github.com/hallettj/pnpm-lock-export
# # # https://github.com/NixOS/nixpkgs/pull/319501
# # { lib
# # , buildNpmPackage
# # , fetchFromGitHub
# # , importNpmLock
# # , inputs
# # }:
# #
# # buildNpmPackage rec {
# #   pname = "vtsls";
# #   version = "0.2.3";
# #
# #   src = fetchFromGitHub {
# #     owner = "yioneko";
# #     repo = "vtsls";
# #     rev = "server-v${version}";
# #     hash = "sha256-rHiH42WpKR1nZjsW+Q4pit1aLbNIKxpYSy7sjPS0WGc=";
# #     fetchSubmodules = true;
# #   };
# #
# #   sourceRoot = "${src.name}/packages/server";
# #
# #   npmDeps = importNpmLock {
# #     npmRoot = "${src}/packages/server";
# #     packageLock = lib.importJSON ./vtsls-package-lock.json;
# #   };
# #
# #   npmDepsHash = "sha256-R70+8vwcZHlT9J5MMCw3rjUQmki4/IoRYHO45CC8TiI=";
# #
# #   npmConfigHook = importNpmLock.npmConfigHook;
# #
# #   dontNpmPrune = true;
# #
# #   meta = with lib; {
# #     description = "LSP wrapper around TypeScript extension bundled with VSCode.";
# #     homepage = "https://github.com/yioneko/vtsls";
# #     license = licenses.mit;
# #     platforms = platforms.all;
# #   };
# # }
# {
#   pkgs,
#   lib,
#   inputs,
#   stdenv,
#   fetchFromGitHub,
#   nodejs,
#   npmHooks,
#   writeScriptBin,
# }:
# stdenv.mkDerivation rec {
#   # src = fetchFromGitHub {
#   #   owner = "bash-lsp";
#   #   repo = "bash-language-server";
#   #   rev = "server-${finalAttrs.version}";
#   #   hash = "sha256-4+imeVjosEspFhWzjtUp2IZx7aZIx56g8M03V3dEGVs=";
#   # };
#
#   pnpm_9 = pkgs.unstable.pnpm_9;
#   pname = "vtsls";
#   version = "0.2.3";
#
#   src = fetchFromGitHub {
#     owner = "yioneko";
#     repo = "vtsls";
#     rev = "server-${version}";
#     hash = "sha256-rHiH42WpKR1nZjsW+Q4pit1aLbNIKxpYSy7sjPS0WGc=";
#     # fetchSubmodules = true;
#   };
#
#   # https://github.com/NixOS/nixpkgs/issues/316908
#   nativeBuildInputs = [
#     nodejs
#     pkgs.unstable.pnpm_9.configHook
#   ];
#   pnpmDeps = pnpm_9.fetchDeps {
#     inherit pname version src;
#     # hash = lib.fakeSha256;
#     hash = "sha256-PpGsJM3wVTqDu4ITXCalqI5XohUb2WOs/yd2BxJ60OE=";
#   };
#   # preBuild = ''
#   # '';
#   # rm -r vscode-client
#   # substituteInPlace tsconfig.json \
#   #   --replace '{ "path": "./vscode-client" },' ""
#   # postBuild = ''
#   #   cd packages/server
#   #   pnpm run build
#   # '';
#   # pnpm --offline deploy --frozen-lockfile  --ignore-script  --filter=bash-language-server server-deploy
#   installPhase = ''
#     mkdir -p $out/{bin,lib/node_modules/vtsls}
#     cp -r packages/server $out
#   '';
#   # cp -r server-deploy $out
# }
{
  bash,
  fetchFromGitHub,
  lib,
  nodejs,
  pkgs,
  inputs,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "vtsls";
  version = "latest";

  src = fetchFromGitHub {
    owner = "yioneko";
    repo = "vtsls";
    rev = "33ab3a11a5fcb3038d10d4f47d91655683b21dbc";
    hash = "sha256-DKJzQj5oD9LN5IHPwaepqGsOWvJjIlkvyutpiInKpDg=";
    # rev = "server-0.2.3";
    # hash = "sha256-rHiH42WpKR1nZjsW+Q4pit1aLbNIKxpYSy7sjPS0WGc=";
    # inherit (inputs.vtsls) rev;
    # hash = inputs.vtsls.narHash;
    fetchSubmodules = true;
    # deepClone = true;
    leaveDotGit = true;
  };

  nativeBuildInputs = [
    # nodejs
    nodejs
    pkgs.unstable.pnpm_9.configHook
    pkgs.git
    # pkgs.pnpm_8.configHook
  ];

  pnpmDeps = pkgs.unstable.pnpm_9.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-NYx8+SVJbB7MZ5Oaw893QqtDmz+AIvaxy1qT6d+oCRU=";
    # hash = "";
    # hash = "sha256-PpGsJM3wVTqDu4ITXCalqI5XohUb2WOs/yd2BxJ60OE=";
  };

  # cd packages/server
  buildPhase = ''
    set -x
    ls -al
    pnpm install
    git status
    git restore --staged .gitmodules
    git submodule status vscode
    ls -al packages/service/vscode/
    # runHook preBuild
    cd packages/service
    pnpm run build

    # runHook postBuild
  '';

  # mv {dist,node_modules} $out/lib/${finalAttrs.pname}
  # echo "#!${lib.getExe bash}
  # ${lib.getExe nodejs} $out/lib/${finalAttrs.pname}/dist/main.js \$@
  # " > $out/bin/vtsls
  # chmod +x $out/bin/vtsls

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,lib/${finalAttrs.pname}}

    runHook postInstall
  '';

  meta = with lib; {
    description = "A stylelint Language Server";
    homepage = "https://github.com/bmatcuk/stylelint-lsp";
    license = licenses.mit;
    maintainers = with maintainers; [gepbird];
    mainProgram = "stylelint-lsp";
    platforms = platforms.unix;
  };
})
