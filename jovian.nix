
# jovian.nix -- Gaming
#
{pkgs, lib, ...}: let
  # Local user account for auto login
  # Separate and distinct from Steam login
  # Can be any name you like
  gameuser = "gamer";
  jovian-nixos = builtins.fetchGit {
    url = "https://github.com/Jovian-Experiments/Jovian-NixOS";
    ref = "development";
  };
in {
  system.activationScripts = {
    print-jovian = {
      text = builtins.trace "building the jovian configuration..." "";
    };
  };

  #
  # Imports
  #
  imports = [ "${jovian-nixos}/modules" ];


  #
  # Hardware
  #
  hardware.xone.enable = true;

  #
  # Jovian
  #
  jovian.hardware.has.amd.gpu = false;
  jovian.steam.enable = true;
  #jovian.devices.steamdeck.enableXorgRotation = lib.mkDefault true;
  #jovian.devices.steamdeck.enableXorgRotation = true;
  jovian.steam.autoStart = true;
  jovian.steam.user = "${gameuser}";
  jovian.steam.desktopSession = "gnome";
  jovian.steamos.useSteamOSConfig = true;
  jovian.decky-loader.enable = true;
  jovian.devices.steamdeck.enableControllerUdevRules = true;

  #
  # Packages
  #
  environment.systemPackages = with pkgs; [
    cmake # Cross-platform, open-source build system generator
    steam-rom-manager # App for adding 3rd party games/ROMs as Steam launch items
  ];

  #
  # SDDM
  #
  services.displayManager.sddm.settings = {
    Autologin = {
      Session = "gamescope-wayland.desktop";
      User = "${gameuser}";
    };
  };

  xdg.portal = {
      enable = true;
    };

  #
  # Steam
  #
  # Set game launcher: gamemoderun %command%
  #   Set this for each game in Steam, if the game could benefit from a minor
  #   performance tweak: YOUR_GAME > Properties > General > Launch > Options
  #   It's a modest tweak that may not be needed. Jovian is optimized for
  #   high performance by default.
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
      };
#      gpu = {
#        apply_gpu_optimisations = "accept-responsibility"; # For systems with AMD GPUs
#        gpu_device = 0;
#        amd_performance_level = "high";
#      };
    };
  };

  programs.steam = {
    enable = true;
    localNetworkGameTransfers.openFirewall = true;
 #   gamescopeSession.args = [ "--force-orientation" "left"];
  };

  #
  # Users
  #
  users = {
    groups.${gameuser} = {
      name = "${gameuser}";
      gid = 10000;
    };

    # Generate hashed password: mkpasswd -m sha-512
    # hashedPassword sets the initial password. Use `passwd` to change it.
    users.${gameuser} = {
      description = "${gameuser}";
      extraGroups = ["gamemode" "networkmanager" "disk" "storage"];
      group = "${gameuser}";
      hashedPassword = "$6$FOpTFgnDq2aJdK4l$0c6L2GXsH.ezqrPzJq0oL35MV0moHo0QsDXSPxnnYet0p7wzh5T7daVQGPPRdKxV8v3i7JBNuYdRqBbcOxroZ0"; # <<<--- Generate your own initial hashed password
      home = "/home/${gameuser}";
      isNormalUser = true;
      uid = 10000;
    };
  };
}

