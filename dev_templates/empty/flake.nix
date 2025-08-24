{
  description = "Development environment ";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = inputs: let
    supportedSystem = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  in
    inputs.flake-utils.lib.eachSystem supportedSystem (system: let
      pkgs = import inputs.nixpkgs {
        inherit system;
      };
      shell = pkgs.mkShell {
        #or mkShellNoCC
        name = "example";
        buildInputs = with pkgs; [
          hello
        ];
        shellHook = ''
          echo "Welcome to Dev shell"
        '';
      };
    in {
      devShells.default = shell;
    })
    // {
      templates.default = {
        path = ./.;
        description = "Development environment template";
      };
    };
}
