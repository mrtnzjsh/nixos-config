{...}: {
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    aggressiveResize = true;
    baseIndex = 1;
    newSession = true;
    historyLimit = 10000;

    extraConfig = ''
      # Set default prefix to Ctrl-a
      unbind C-b
      set -g prefix C-a
      bind C-a send-prefix

      # Enable mouse support
      set -g mouse on

      # Don't exit copy mode when dragging with mouse
      unbind -T copy-mode-vi MouseDragEnd1Pane

      # Scroll with mouse in copy mode
      bind -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'copy-mode -e'"

      # Renumber windows sequentially
      set -g renumber-windows on

      # Scrollback buffer size
      set -g history-limit 10000

      # Vi-like mode
      setw -g mode-keys vi

      # Split panes using | and -
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # Resize panes with prefix and arrow keys
      bind H resize-pane -L 5
      bind J resize-pane -D 5
      bind K resize-pane -U 5
      bind L resize-pane -R 5

      # Move panes
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Quick pane navigation
      bind -r C-h select-pane -L
      bind -r C-j select-pane -D
      bind -r C-k select-pane -U
      bind -r C-l select-pane -R

      # Reload config
      bind r run-shell "tmux source-file ~/.config/tmux/tmux.conf && tmux display-message 'Config reloaded'"

      # Status bar configuration
      set -g status-position bottom
      set -g status-justify left
      set -g status-bg '#1e1e2e'
      set -g status-fg '#cdd6f4'
      set -g status-left-length 50
      set -g status-right-length 50
      setw -g window-status-current-format ' #I:#[fg=red]#W#[fg=cyan]#F '
      setw -g window-status-format ' #I:#[fg=white]#W#[fg=white]#F '
      set -g status-left '#[fg=red]#S#[fg=white] '
      set -g status-right '#{?window_busy,#[fg=red]*}#[fg=green]#(whoami)@#H #[fg=blue]%H:%M #[fg=yellow]%d-%b-%y '

      # Pane borders
      set -g pane-border-style fg='#313244'
      set -g pane-active-border-style fg='#f38ba8'

      # Colors for copy mode
      setw -g window-status-current-style "fg=#89b4fa,bg=#1e1e2e"
      setw -g window-status-style "fg=#cdd6f4,bg=#1e1e2e"
    '';
  };
}
