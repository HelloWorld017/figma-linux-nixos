{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    systems = {
      url = "github:nix-systems/default-linux";
    };
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      name = "figma-linux-nixos";
      version = "0.11.5";
    in {
      packages.default = pkgs.buildNpmPackage {
        pname = name;
        version = version;

        src = pkgs.fetchFromGitHub {
          owner = "Figma-Linux";
          repo = "figma-linux";
          rev = "v${version}";
          hash = "sha256-pa0GgAmi9Os4EtZpbo0hSgr4s+WX95zLUrZR8a33TeI=";
        };

        patches = [
          ./patches/0001-fontdir.patch
        ];

        npmDepsHash = "sha256-FqgcG52Nkj0wlwsHwIWTXNuIeAs7b+TPkHcg7m5D2og=";
        dontNpmBuild = true;

        buildInputs = [
          pkgs.libGL
        ];

        nativeBuildInputs = [
          pkgs.copyDesktopItems
          pkgs.makeWrapper
        ];

        buildPhase = ''
          runHook preBuild
          npm install
          npm run build
          npm prune --production
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out/app
          cp package.json $out/app
          cp -r dist/* $out/app
          cp -r node_modules $out/app

          makeWrapper ${pkgs.electron}/bin/electron $out/bin/figma-linux \
            --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [ pkgs.libGL ]}" \
            --add-flags "$out/app/main/main.js" \
            --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime=true}}"

          runHook postInstall
        '';

        env = { ELECTRON_SKIP_BINARY_DOWNLOAD = 1; };

        desktopItems = [
          (pkgs.makeDesktopItem {
            name = "figma-linux";
            desktopName = "Figma Linux";
            exec = "figma-linux %U";
            terminal = false;
            startupWMClass = "figma-linux";
            type = "Application";
            mimeTypes = [ "x-scheme-handler/figma" "application/figma" ];
          })
        ];

      };
    });
}
