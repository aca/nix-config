[private]  
@default:  
  @just --list

rebuild_oci-aca-001:
    nixos-rebuild switch --fast --flake '.#oci-aca-001' --target-host root@oci-acadx-001 --build-host root@oci-acadx-001
    

