# Nix Shell

- [mkShell](https://github.com/NixOS/nixpkgs/blob/dd4070b45f7c18fba29ce00ff979c19b389350ae/doc/build-helpers/special/mkshell.section.md)

> [!note]
>
> I was looking some option or setting to use zsh in the nix-shell, but the solution was really obvious as illustrated in [this gist](https://gist.github.com/bscott/0c1be04cb43520ca7453f9cd3ce98f38). All I had to do was call `zsh` in the `shellHook`.
