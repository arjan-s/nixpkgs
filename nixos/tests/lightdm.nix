{ pkgs, ... }:
{
  name = "lightdm";
  meta = with pkgs.lib.maintainers; {
    maintainers = [ aszlig ];
  };

  nodes.machine =
    { ... }:
    {
      imports = [ ./common/user-account.nix ];
      services.xserver.enable = true;
      services.xserver.displayManager.lightdm.enable = true;
      services.displayManager.defaultSession = "none+icewm";
      services.xserver.windowManager.icewm.enable = true;
    };

  enableOCR = true;

  testScript =
    { nodes, ... }:
    let
      user = nodes.machine.config.users.users.alice;
    in
    ''
      start_all()
      machine.wait_for_text("${user.description}")
      machine.screenshot("lightdm")
      machine.send_chars("${user.password}\n")
      machine.wait_for_file("${user.home}/.Xauthority")
      machine.succeed("xauth merge ${user.home}/.Xauthority")
      machine.wait_for_window("^IceWM ")
    '';
}
