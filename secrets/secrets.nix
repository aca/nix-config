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
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL5/DkiXdSA2OJhCq7t931LhBy80G53DWk3/2X0BhI4V rok@sm-a556e"
  ];
  "archive-0" = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFfxHScKB7GKZGf+gCDAYHsSGv8EscVIsK9fSneO3Kt/ root@archive-0"
  ];
  seedbox-impx = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGc8lSwAeCMM+HVRsMXZOJ1ECxF6wuEEqMQPvqTnkmwH rok@home.local"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4PDiS3q4XfHGXd2om/ErP8kYr3dymD84XON3PTgBbM rok@rok-x1g10"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE1/AnZwRhG2fR7PuT+Znr6vwApShX/nZAG6bfkay+BK root@seedbox-impx"
  ];
  "txxx-nix" = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICRKLyspdv+Xb8NF2bc6e5FUQ/FFXsxG82Wy+BuyPYY5 rok@txxx-nix"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEICO4lAMa0WCZZHq6TAXcVwks0T5xo+w15pS4P9jrrz rok@tsvm"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGb7iO/gQTb52HPZH98+LK/BvZ0bEEYXN58LtIyQ9snT root@tsvm"
  ]
  ++ home;
  "oci-aca-001" = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIhIGvIYjtlbwKZcLEGSMi7iB5/0oZDDItPDmnbFUAw3 root@oci-aca-001"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEVJ2WbU6FYfLucoPDvzucRe73Ks9xv8qDvngx0ZsCXL rok@oci-aca-001"
  ]
  ++ home;
  "oci-jkor" = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGYspEHMoCh21HmElvLPZ41yJ0LxECryjaz20NbvnfMZ root@jkorroot"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6VK7jw/srNQIzOFB9t9GTvPQSokkrJaqCrX1TyTk2XL4yZzk0aZ9GjznXiBSPdGX+I1KIjfsbRkasrLLcKByy/xacki0w2/fh28tmEEqGozzItBXJjmBHqLSt2v2KzzuF7jSKXptvDik82WqA1FpYYUPYeD949ock5ijph8UXt94NKNoCFlPFciag+fAEPLHNgwZm7y2ABukw/bIrxk5oZPS5UMOS3iUGTBdl6W7u9vuwo4TwlMChuIZZD+QR6a3nnlMPlzgA1430U+I18kjI30TfLhPGZ5RgzlPzQFL72ulFwvkKKyzvJSCh8SxPqlFEfKhp7uy7GhA67r/+aMkh75XiYPU1epBljUpAwgX7z/K+Oii0tYvNJ8NZgA/Be2TrOqBYZdvZc6sAEw4bHaijwyt0EPmPz74fB5uzQ7Vo0cFOo4vhia3PAHPSeHvV0NCtrf85mvy7hHKgPI2I/Ld9eGVa4WFSy/LuvDLMbAu0wyc26avqfYYg1os5LV9Nqz8= root@jkorroot"
  ]
  ++ home;
in
{
  "hosts.age".publicKeys = txxx-nix;
  "env.txxx-nix.age".publicKeys = txxx-nix;
  "env.sm-a556e.age".publicKeys = home;
  "home/env.age".publicKeys = home;
  "env.seedbox-impx.age".publicKeys = seedbox-impx;
  "github.com__aca.age".publicKeys = systems;
  "oci-aca-001/services.matrix-synapse.extraConfigFiles.registration_shared_secret.age".publicKeys =
    oci-aca-001;
  "oci-aca-001.nix.age".publicKeys = oci-aca-001;
  "oci-aca-001/env.age".publicKeys = oci-aca-001;

  "xxxxx.age".publicKeys = home;
  "agenixtest.age".publicKeys = txxx;
  "txxx.age".publicKeys = txxx;
  "msmtp.accounts.gmail.password.age".publicKeys = home;
  "github.com__aca__oci-aca-002.age".publicKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICbYB4RbI25LHP8/kfc6zBsb+N9t/t2HGdH3qBjKuaKF root@oci-aca-002"
  ];

  "var1.age".publicKeys = home;
  "archive-0.age".publicKeys = home ++ archive-0;

  "oci-jkor/services.matrix-synapse.extraConfigFiles.age".publicKeys = oci-jkor;

  # "tailscale.com/root".publicKeys = [];
}
