{
  config,
  pkgs,
  lib,
  inputs,
  modules,
  ...
}: let
  hostname = config.networking.hostName;
  binscripts =
    builtins.mapAttrs (name: text: builtins.readFile ((builtins.toString ./.) + "/scripts.darwin/${name}"))
    (
      lib.filterAttrs (
        key: value:
          value
          == "regular"
          && key != "tsconfig.json"
          && key != "bun.lockb"
          && key != "package.json"
          && key != ".gitignore"
      ) (builtins.readDir ./scripts.darwin)
    );
in {
  environment.systemPackages =
    (map (
      name: (pkgs.writeTextFile {
        name = name;
        text = binscripts.${name};
        executable = true;
        destination = "/bin/${name}";
      })
    ) (builtins.attrNames binscripts));

}
