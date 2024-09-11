let
  systems = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFgWhwNjnsMYxsFs388V2z8+G9sUpsCMP1FTpU9d+5T root@oci-xnzm1001-001"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10"
  ];
  # "p2p_clipboard" = [
  #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFgWhwNjnsMYxsFs388V2z8+G9sUpsCMP1FTpU9d+5T root@oci-xnzm1001-001"
  #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10"
  # ];
  root = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10"
  ];
  txxx = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/acNBaXuGBqtEyJoSMkrWXKYgQ/Q9c52SChgmh1ssT rok@rok-txxx-nix"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICd7exUEooSLkYtH4UZrQrjKwOJBD5xtdC4ROuf3U0f7 rok@rok-txxx"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGc8lSwAeCMM+HVRsMXZOJ1ECxF6wuEEqMQPvqTnkmwH rok@home"
  ];
  home = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGc8lSwAeCMM+HVRsMXZOJ1ECxF6wuEEqMQPvqTnkmwH rok@home.local"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHPvB51sf9oUql9cL7rWmpN8D5maKzXqgmKlJ8rfcyEI root@archive-0"
  ];
in {
  "github.com__aca.age".publicKeys = systems;
  "home.services.matrix-sliding-sync.environmentFile.age".publicKeys = home;
  "home.services.matrix-synapse.registration_shared_secret.age".publicKeys = home;
  "home.services.matrix-synapse.extraConfigFiles.registration_shared_secret_path.age".publicKeys = home;
  "xxxxx.age".publicKeys = home;
  "agenixtest.age".publicKeys = home;
  "txxx.age".publicKeys = txxx;
}
