{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  # pkgs.mkShellNoCC { # if no C compiler is needed
  name = "nx-zsh";

  packages = [
    pkgs.zsh
  ];

  inputsFrom = [
    # pkgs.zsh
  ];

  shellHook = ''
    zsh # start zsh shell
    export NIX_SHELL_TEST="This is a test env var"
  '';
}
