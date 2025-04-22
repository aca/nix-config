let
  systems = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFgWhwNjnsMYxsFs388V2z8+G9sUpsCMP1FTpU9d+5T root@oci-xnzm-001"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10"
  ];
  # "p2p_clipboard" = [
  #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFgWhwNjnsMYxsFs388V2z8+G9sUpsCMP1FTpU9d+5T root@oci-xnzm-001"
  #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10"
  # ];
  root = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10"
  ];
  txxx = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/acNBaXuGBqtEyJoSMkrWXKYgQ/Q9c52SChgmh1ssT rok@txxx-nix"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICd7exUEooSLkYtH4UZrQrjKwOJBD5xtdC4ROuf3U0f7 rok@txxx"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGc8lSwAeCMM+HVRsMXZOJ1ECxF6wuEEqMQPvqTnkmwH rok@home"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINFtTatYMZTv5Htv9VcEnAXcbc/EfwulDEqesJfua0K8 dummy"
  ];
  home = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGc8lSwAeCMM+HVRsMXZOJ1ECxF6wuEEqMQPvqTnkmwH rok@home.local"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHPvB51sf9oUql9cL7rWmpN8D5maKzXqgmKlJ8rfcyEI root@archive-0"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10"
  ];
  oci-impx-001 = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQSK/DE+ME45yO5Xnm3OSO6w+Ck1gqDQhcK7NCcA0l5 rok@oci-impx-001"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGc8lSwAeCMM+HVRsMXZOJ1ECxF6wuEEqMQPvqTnkmwH rok@home.local"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10"
  ];
  "txxx-nix" = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICRKLyspdv+Xb8NF2bc6e5FUQ/FFXsxG82Wy+BuyPYY5 rok@txxx-nix"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGc8lSwAeCMM+HVRsMXZOJ1ECxF6wuEEqMQPvqTnkmwH rok@home.local"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10"
  ];
  "mx-synapse" = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILDZidt5wV1NEEbqwuzAjRqu8YGbrBSzlyME4X7PAZn7 root@oci-aca-001"
  ] ++ home;
in
{
  "hosts.age".publicKeys = txxx-nix;
  "env.txxx-nix.age".publicKeys = txxx-nix;
  "env.home.age".publicKeys = home;
  "env.oci-impx-001.age".publicKeys = oci-impx-001;
  "github.com__aca.age".publicKeys = systems;
  "mx-synapse.extraConfigFiles.registration_shared_secret.age".publicKeys = mx-synapse;

  "home.services.matrix-sliding-sync.environmentFile.age".publicKeys = home;
  "home.services.matrix-synapse.registration_shared_secret.age".publicKeys = home;
  "home.services.matrix-synapse.extraConfigFiles.registration_shared_secret.age".publicKeys = home;
  "home.services.matrix-synapse.extraConfigFiles.registration_shared_secret_path.age".publicKeys =
    home;

  "xxxxx.age".publicKeys = home;
  "agenixtest.age".publicKeys = txxx;
  "txxx.age".publicKeys = txxx;
  "msmtp.accounts.gmail.password.age".publicKeys = home;
  "github.com__aca__oci-aca-002.age".publicKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICbYB4RbI25LHP8/kfc6zBsb+N9t/t2HGdH3qBjKuaKF root@oci-aca-002"
  ];
  # "tailscale.com/root".publicKeys = [];
}
