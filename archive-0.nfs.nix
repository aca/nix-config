{
  config,
  pkgs,
  lib,
  ...
}: {
  # NFS
  # mergerfs+nfs requirements https://github.com/trapexit/mergerfs?tab=readme-ov-file#nfs
  # fsid is randomly generated. Don't need to change.
  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /mnt/archive-0    192.168.0.0/24(rw,nohide,insecure,no_subtree_check,all_squash,anonuid=0,anongid=0,fsid=9eebb861-b9b3-415d-a2ff-bd0ab28ff29a)
    /mnt/data01    192.168.0.0/24(rw,nohide,insecure,no_subtree_check,all_squash,anonuid=0,anongid=0)
    /mnt/data02    192.168.0.0/24(rw,nohide,insecure,no_subtree_check,all_squash,anonuid=0,anongid=0)
    /mnt/data03    192.168.0.0/24(rw,nohide,insecure,no_subtree_check,all_squash,anonuid=0,anongid=0)
    /mnt/data04    192.168.0.0/24(rw,nohide,insecure,no_subtree_check,all_squash,anonuid=0,anongid=0)
    /mnt/data05    192.168.0.0/24(rw,nohide,insecure,no_subtree_check,all_squash,anonuid=0,anongid=0)
    /mnt/data06    192.168.0.0/24(rw,nohide,insecure,no_subtree_check,all_squash,anonuid=0,anongid=0)
    /mnt/data07    192.168.0.0/24(rw,nohide,insecure,no_subtree_check,all_squash,anonuid=0,anongid=0)
    /mnt/data08    192.168.0.0/24(rw,nohide,insecure,no_subtree_check,all_squash,anonuid=0,anongid=0)
    /mnt/data09    192.168.0.0/24(rw,nohide,insecure,no_subtree_check,all_squash,anonuid=0,anongid=0)
  '';
}
