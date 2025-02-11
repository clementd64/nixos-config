{ config, lib, ... }:

let cfg = config.clement.htop;
in with lib; {
  options.clement.htop = {
    enable = mkEnableOption "htop";
  };

  config = mkIf cfg.enable {
    programs.htop = {
      enable = true;
      settings = {
        detailed_cpu_time = 1;
        hide_userland_threads = 1;
        highlight_base_name = 1;
        screen_tabs = 1;
        show_cpu_frequency = 1;
        show_cpu_temperature = 1;
      } // (with config.lib.htop; leftMeters [
        (bar "CPU")
        (bar "Memory")
        (bar "Zram")
        (bar "LeftCPUs")
      ]) // (with config.lib.htop; rightMeters [
        (text "Tasks")
        (text "LoadAverage")
        (text "Uptime")
        (bar "RightCPUs")
      ]);
    };

    xdg.configFile."htop/htoprc".force = true;
  };
}
