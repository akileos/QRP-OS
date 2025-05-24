{
  description = "Lightweight QRP Radio OS based on NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-generators, ... }:
    let
      # Only Linux systems can build NixOS
      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      allSystems = [ "x86_64-linux" "aarch64-linux" ];
      
      editions = [ "swl" "digimodes" "cw" "full" ];
      architectures = [ "x86" "rpi3" "rpi4" "rpi400" "rpizero2w" "rpi5" ];
      
      # Helper to generate all combinations
      combinations = nixpkgs.lib.flatten (map (edition:
        map (arch: { inherit edition arch; }) architectures
      ) editions);
      
      # Generate for all systems
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f system);
      forLinuxSystems = f: nixpkgs.lib.genAttrs linuxSystems (system: f system);
      
      # Get system for architecture
      getSystem = arch: 
        if builtins.elem arch [ "rpi3" "rpi4" "rpi400" "rpizero2w" "rpi5" ] 
        then "aarch64-linux" 
        else "x86_64-linux";

      # Get image format string for nixos-generators
      getNixosGeneratorFormat = arch:
        if arch == "x86" then "iso"
        else if arch == "rpi3" then "sd-aarch64"
        else if arch == "rpi4" then "sd-aarch64" 
        else if arch == "rpi400" then "sd-aarch64"
        else if arch == "rpizero2w" then "sd-aarch64"
        else if arch == "rpi5" then "sd-aarch64"
        else "raw"; # A generic fallback, though not used by current architectures
              
    in
    {
      nixosConfigurations = nixpkgs.lib.listToAttrs (map ({ edition, arch }: {
        name = "${edition}-${arch}";
        value = nixpkgs.lib.nixosSystem {
          system = getSystem arch;
          modules = [
            ./modules/${edition}-edition.nix
            ./hardware/${arch}-minimal.nix
            ./images/base-image.nix
            # Build optimization
            {
              nix.settings = {
                max-jobs = "auto";
                cores = 0; # Use all available cores
                auto-optimise-store = true;
              };
            }
          ];
        };
      }) combinations);

      packages = forAllSystems (system: 
        let 
          pkgs = nixpkgs.legacyPackages.${system};
        in
        if builtins.elem system linuxSystems then
          # Linux: Build ISOs or IMGs
          (nixpkgs.lib.listToAttrs (
            map ({ edition, arch }: 
              let nixosGenFormat = getNixosGeneratorFormat arch; in
              {
              name = "${edition}-${arch}-${nixosGenFormat}"; # e.g., swl-x86-iso or digimodes-rpi4-sd-rpi4
              value = nixos-generators.nixosGenerate {
                inherit system;              modules = [
                ./modules/${edition}-edition.nix
                ./hardware/${arch}-minimal.nix
                ./images/base-image.nix
                # Build optimization
                {
                  nix.settings = {
                    max-jobs = "auto";
                    cores = 0; # Use all available cores
                    auto-optimise-store = true;
                  };
                }
              ] ++ nixpkgs.lib.optional (arch == "x86") {
                  isoImage.isoName = "qrp-os-${edition}-${arch}.iso";
                } ++ nixpkgs.lib.optional (builtins.elem arch [ "rpi3" "rpi4" "rpi400" "rpizero2w" "rpi5" ]) {
                  sdImage.imageName = "qrp-os-${edition}-${arch}.img";
                };
                format = nixosGenFormat; # Use the nixos-generators specific format string
              };
            }) (nixpkgs.lib.filter ({ edition, arch }: 
              getSystem arch == system
            ) combinations)
          )) // {
            # Default package for Linux (swl-x86-iso)
            default = nixos-generators.nixosGenerate {
              inherit system;            modules = [
              ./modules/swl-edition.nix
              ./hardware/x86-minimal.nix
              ./images/base-image.nix
              # Build optimization
              {
                nix.settings = {
                  max-jobs = "auto";
                  cores = 0; # Use all available cores
                  auto-optimise-store = true;
                };
              }
              {
                isoImage.isoName = "qrp-os-swl-x86.iso";
              }
            ];
              format = "iso"; # nixos-generators format for x86
            };
          }
        else
          # macOS/other: Provide development shell
          {
            default = pkgs.mkShell {
              buildInputs = with pkgs; [
                git
                vim
                nixfmt
              ];
              shellHook = ''
                echo "🎯 QRP Radio NixOS Development Environment"
                echo "📡 Available editions: ${builtins.concatStringsSep ", " editions}"
                echo "💻 Available architectures: ${builtins.concatStringsSep ", " architectures}"
                echo ""
                echo "🚀 To build images (requires Linux or a Linux builder):"
                echo "   nix build .#swl-x86-iso" 
                echo "   nix build .#digimodes-rpi4-sd-aarch64"
                echo "   nix build .#swl-rpizero2w-sd-aarch64  # Optimized for 512MB RAM"
                echo "   nix build .#full-rpi400-sd-aarch64" 
                echo ""
                echo "🔧 To test configurations (on Linux):"
                echo "   nixos-rebuild build-vm --flake .#swl-x86"
              '';
            };
          }
      );

      # Development shell for all systems
      devShells = forAllSystems (system:
        let 
          pkgs = nixpkgs.legacyPackages.${system};
          isLinux = builtins.elem system linuxSystems;
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              git
              vim
              nixfmt
            ] ++ nixpkgs.lib.optionals isLinux [
              # Linux-only tools
              nixos-rebuild
            ];
            
            shellHook = ''
              echo "🎯 QRP Radio NixOS Development Environment"
              echo "📡 Available editions: ${builtins.concatStringsSep ", " editions}"
              echo "💻 Available architectures: ${builtins.concatStringsSep ", " architectures}"
              echo ""
              ${if isLinux then ''
                echo "🚀 Build commands:"
                echo "   nix build .#swl-x86-iso" 
                echo "   nix build .#digimodes-rpi4-sd-aarch64"
                echo "   nix build .#swl-rpizero2w-sd-aarch64  # Optimized for 512MB RAM"
                echo "   nix build .#full-rpi400-sd-aarch64" 
                echo ""
                echo "🔧 Test commands:"
                echo "   nixos-rebuild build-vm --flake .#swl-x86"
              '' else ''
                echo "🍎 Running on macOS - use remote Linux builder for image builds:"
                echo "   nix build .#swl-x86-iso --builders 'ssh://user@linux-machine x86_64-linux'" 
                echo "   nix build .#digimodes-rpi4-sd-aarch64 --builders 'ssh://user@linux-machine aarch64-linux'"
                echo "   nix build .#swl-rpizero2w-sd-aarch64 --builders 'ssh://user@linux-machine aarch64-linux'"
                echo "   nix build .#full-rpi400-sd-aarch64 --builders 'ssh://user@linux-machine aarch64-linux'" 
              ''}
              echo ""
              echo "📝 Edit configurations in:"
              echo "   modules/     - Edition definitions"
              echo "   hardware/    - Hardware profiles"
            '';
          };
        }
      );
    };
}