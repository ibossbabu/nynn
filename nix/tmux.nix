{
  inputs,
  pkgs,
  ...
}: let
  plugins = with pkgs.tmuxPlugins; [
    sensible
    vim-tmux-navigator
    continuum
    resurrect
    yank
    catppuccin
  ];

  runtimeInputs = [pkgs.tmux] ++ plugins;

  tx = pkgs.writeShellApplication {
    name = "tx";
    inherit runtimeInputs;
    text = ''
      export TMUX_PLUGIN_SENSIBLE="${pkgs.tmuxPlugins.sensible.rtp}"
      export TMUX_PLUGIN_CATPPUCCIN="${pkgs.tmuxPlugins.catppuccin.rtp}"
      export TMUX_PLUGIN_VIM_NAVIGATOR="${pkgs.tmuxPlugins.vim-tmux-navigator.rtp}"
      export TMUX_PLUGIN_CONTINUUM="${pkgs.tmuxPlugins.continuum.rtp}"
      export TMUX_PLUGIN_RESURRECT="${pkgs.tmuxPlugins.resurrect.rtp}"
      export TMUX_PLUGIN_YANK="${pkgs.tmuxPlugins.yank.rtp}"
      exec tmux -f ${./.tmux.conf} "$@"
    '';
  };
in {
  package = tx;
  app = {
    type = "app";
    program = "${tx}/bin/tx";
  };
}
