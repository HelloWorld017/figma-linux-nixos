# Figma Linux NixOS
This project aims to fix bugs which hinder me from using the Figma in NixOS.

## Bugs
* Hardware Acceleration is not working
* Fonts are not found
* Resizing makes UI glitches.

## Usage
```nix
# 1. Add `figma-linux` to the flake input
figma-linux = {
    url = "github:HelloWorld017/figma-linux-nixos";
    inputs.nixpkgs.follows = "nixpkgs";
};

# 2. Enable the `fontDir` option in the NixOS module
fonts.fontDir.enable = true

# 3. Use the package
inputs.figma-linux.packages.${system}.default
```

## Upstreaming Plan
* TBD
