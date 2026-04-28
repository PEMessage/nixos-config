{ inputs, ... }:
{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    chezmoi
    neovim
    gh
    uv
  ];

    home.file.".profile".text = ''
      # if running bash
      if [ -n "$BASH_VERSION" ]; then
        # include .bashrc if it exists
        if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
        fi
      fi
    '';

    # This must be LF, CRLF will cause error
    # Use `nix derivation` to debug
    home.activation.runChezmoi = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -d "$HOME/.local/share/chezmoi" ] ; then
        echo "Initializing chezmoi dotfiles..." ;
        ${pkgs.chezmoi}/bin/chezmoi init --branch linux-v2 --apply pemessage --depth 1 ;
      fi
    '';

  home.stateVersion = "25.11";
}
