#!/usr/bin/env -S nix shell nixpkgs#crane --command bash
TMPDIR=$(mktemp -d)
crane export --platform linux/amd64 "$1" - | tar xC $TMPDIR
mkdir -p $TMPDIR/{dev,proc,sys,run,tmp,var/tmp}
nix-hash --type sha256 $TMPDIR
rm -rf $TMPDIR
