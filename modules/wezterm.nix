{pkgs, ...}: let
  theme =
    if pkgs.stdenv.isDarwin
    then "Tokyo Night"
    else "Batman";
  font =
    if pkgs.stdenv.isDarwin
    then "JetBrainsMono Nerd Font"
    else "JetBrains Mono Nerd Font";
in {
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = wezterm.config_builder()

      config.color_scheme = '${theme}'
      config.font = wezterm.font '${font}'
      config.font_size = 12.0

      config.front_end = "WebGpu"
      config.enable_tab_bar = false

      return config
    '';
  };
}
