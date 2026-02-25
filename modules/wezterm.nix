{pkgs, ...}: {
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = wezterm.config_builder()

      config.color_scheme = 'Batman'
      config.font = wezterm.font 'JetBrains Mono Nerd Font'
      config.font_size = 12.0

      config.front_end = "WebGpu"
      config.enable_tab_bar = false

      return config
    '';
  };
}
