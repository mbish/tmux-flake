{
  pkgs,
  lib,
  zsh,
  system,
  ...
}: let
  zshBin = "${zsh.packages.${system}.default}/bin/zsh";
  tmuxinatorBin = "${pkgs.tmuxinator}/bin/tmuxinator";
  egrepBin = "${pkgs.gnugrep}/bin/egrep";
  perlBin = "${pkgs.perl}/bin/perl";
  xclipBin = "${pkgs.xclip}/bin/xclip";
  powerlineConfigBin = "${pkgs.powerline}/bin/powerline-config";
  powerlineDaemonBin = "${pkgs.powerline}/bin/powerline-daemon";
in
  with lib;
    pkgs.writeTextFile {
      name = "tmux.conf";
      text = ''
        set-option -g default-shell ${zshBin}
        set -g history-limit 1000000
        set -g default-terminal "tmux-256color"
        set -ga terminal-overrides ",*256col*:Tc"
        set -g default-terminal "xterm-256color"
        set -g base-index 1
        set-option -g prefix C-s
        set-window-option -g mode-keys vi
        bind-key C-s last-window
        setw -g mode-keys vi # I especially like being able to search with /,? when in copy-mode
        unbind-key j
        bind-key j select-pane -D # Similar to 'C-w j' to navigate windows in Vim
        unbind-key k
        bind-key k select-pane -U
        unbind-key h
        bind-key h select-pane -L
        unbind-key l
        bind-key l select-pane -R
        unbind-key C-v
        bind-key C-v split-window -h
        unbind-key C-b
        bind-key C-b split-window -v
        unbind-key C-q
        bind-key C-q kill-pane
        unbind-key q
        bind-key q kill-pane
        unbind-key C-t
        unbind-key t
        bind-key C-t command-prompt "new-session -s '%%'"
        bind-key t command-prompt "new-session -s '%%'"
        unbind-key r
        bind-key r   command-prompt "rename-session '%%'"
        unbind-key A
        bind-key A command-prompt "rename-window '%%'"
        bind-key C-n next-window
        bind-key C-p previous-window
        bind-key c new-window -c'#{pane_current_path}'
        bind-key C-c new-window -c'#{pane_current_path}'
        bind-key C-m setw monitor-silence 30
        bind-key C-l setw monitor-silence 120
        bind-key C-j command-prompt -p "mux start" "run-shell -t 9 '${tmuxinatorBin} start %%'"
        bind-key -n C-Space last-window
        setw -g mouse off

        # Set status bar
        set -g status-left '#[fg=green]#S'
        set -g status-right '#[fg=yellow]#(uptime | ${egrepBin} -o "[0-9]+ users?, +load.*"|${perlBin} -pe "s| averages?||"), %H:%M'
        set-window-option -g aggressive-resize

        # Highlight active window
        set-window-option -g mode-keys vi
        bind-key -T copy-mode-vi 'v' send -X begin-selection
        set -s escape-time 0
        set -g focus-events on
        bind -T copy-mode-vi 'y' send-keys -X copy-pipe-and-cancel "${xclipBin} -i -f -selection primary | ${xclipBin} -i -selection clipboard"
        bind -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "${xclipBin} -i -f -selection primary | ${xclipBin} -i -selection clipboard"
        run-shell '${powerlineDaemonBin} -q'
        run-shell '${powerlineConfigBin} tmux setup'
        # ################################################
        set-option -g status-interval 1
      '';
    }
