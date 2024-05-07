{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  # pkgs.mkShellNoCC { # if no C compiler is needed

  # (default: nix-shell). Set the name of the derivation.
  name = "test shell";

  # (default: []). Add executable packages to the nix-shell environment.
  packages = [
    pkgs.zsh
  ];

  # (default: []). Add build dependencies of the listed derivations to the nix-shell environment.
  inputsFrom = [ ];

  # (default: ""). Bash statements that are executed by nix-shell.
  shellHook = ''
    zsh -l # start zsh shell
    export NIX_SHELL_TEST="This is a test env var"
    echo $NIX_SHELL_TEST
  '';
}
