# System-wide keyboard chattering (switch bounce / double-typing) fix.
#
# Uses interception-tools so udevmon automatically grabs every keyboard
# (matched by EV_KEY: KEY_ENTER) and re-emits its events through a small
# debounce filter. Works at the evdev/uinput layer, below the compositor,
# so it applies to sway and to any keyboard - wired, wireless or Bluetooth,
# including hotplug (a keyboard connecting later is picked up automatically).
{
  config,
  pkgs,
  lib,
  ...
}:
let
  kb-debounce = pkgs.buildGoModule {
    pname = "kb-debounce";
    version = "0.1";
    src = ./kb-debounce;
    vendorHash = null; # no external dependencies
  };

  # Drop a key-down arriving within this many ms of the same key's release.
  debounceMs = 20;
in
{
  services.interception-tools = {
    enable = true;
    plugins = [ kb-debounce ];
    udevmonConfig = ''
      # JOB: the shell pipeline udevmon runs for each matching device.
      #   intercept -g $DEVNODE : grab the device exclusively and stream its
      #                           raw events to stdout
      #   kb-debounce           : drop chatter, pass everything else through
      #   uinput   -d $DEVNODE  : re-emit the cleaned events as a virtual clone
      #                           of the original device (same name/caps)
      - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | DEBOUNCE_MS=${toString debounceMs} ${kb-debounce}/bin/kb-debounce | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
        # DEVICE: which devices this JOB attaches to. This is a *capability*
        # filter, not a key whitelist - the JOB still intercepts ALL keys of a
        # matched device. udevmon re-checks this on every hotplug event, so a
        # keyboard plugged/connected later (incl. Bluetooth) is picked up too.
        DEVICE:
          EVENTS:
            # Attach only to devices able to emit KEY_ENTER, i.e. keyboards.
            # Mice/touchpads lack this capability and are left untouched.
            EV_KEY: [KEY_ENTER]
    '';
  };
}
