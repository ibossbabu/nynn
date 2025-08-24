{
  description = "Sakhollow Neovim-Custom Setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs @ {
    self,
    flake-utils,
    nixpkgs,
    neovim-nightly-overlay,
    ...
  }: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    neovim-overlay = import ./nix/nvim-overlay.nix {inherit inputs;};
  in
    flake-utils.lib.eachSystem supportedSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            inputs.neovim-nightly-overlay.overlays.default
            neovim-overlay
          ];
        };

        tmuxModule = import ./nix/tmux.nix {
          inherit inputs pkgs;
        };

        nvimconf = ./nix/nvim;

        mylink = pkgs.writeShellScript "my-link" ''
            mkdir -p "$HOME/.config"
          rm -rf "$HOME/.config/nvim"
          rsync -av --chmod=u+w "${nvimconf}/" "$HOME/.config/nvim/"
          echo "Neovim config linked successfully!"
        '';

        shell = pkgs.mkShellNoCC {
          name = "nvim-devShell";
          buildInputs = with pkgs; [
            myNeovim
            fzf
            git
            direnv
            ripgrep
            fd
            tree
          ];
        };
      in {
        packages = {
          default = pkgs.myNeovim;
          tmux = tmuxModule.package;
        };
        devShells.default = shell;
        apps = {
          default = {
            type = "app";
            program = "${pkgs.myNeovim}/bin/nvim";
          };
          link = {
            type = "app";
            program = "${mylink}";
          };
          tmux = tmuxModule.app;
        };
      }
    );
}
