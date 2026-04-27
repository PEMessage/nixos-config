{ inputs, ... }:
{ config, lib, pkgs, ... }:
{
    home.packages = with pkgs; [
        chezmoi
    ];

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
