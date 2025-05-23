{
  description = "Lightweight HAM Radio OS based on NixOS";

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
      allSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      
      editions = [ "swl" "digimodes" "cw" "full" ];
      architectures = [ "x86" "rpi3" "rpi4" "rpi5" ];
      
      # Helper to generate all combinations
      combinations = nixpkgs.lib.flatten (map (edition:
        map (arch: { inherit edition arch; }) architectures
      ) editions);
      
      # Generate for all systems
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f system);
      forLinuxSystems = f: nixpkgs.lib.genAttrs linuxSystems (system: f system);
      
      # Get system for architecture
      getSystem = arch: 
        if builtins.elem arch [ "rpi3" "rpi4" "rpi5" ] 
        then "aarch64-linux" 
        else "x86_64-linux";
              
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
            {
              # Set ISO name dynamically
              isoImage.isoName = "ham-radio-${edition}-${arch}.iso";
            }
          ];
        };
      }) combinations);

      packages = forAllSystems (system: 
        let 
          pkgs = nixpkgs.legacyPackages.${system};
        in
        if builtins.elem system linuxSystems then
          # Linux: Build ISOs
          (nixpkgs.lib.listToAttrs (
            map ({ edition, arch }: {
              name = "${edition}-${arch}-iso";
              value = nixos-generators.nixosGenerate {
                inherit system;
                modules = [
                  ./modules/${edition}-edition.nix
                  ./hardware/${arch}-minimal.nix
                  ./images/base-image.nix
                  {
                    isoImage.isoName = "ham-radio-${edition}-${arch}.iso";
                  }
                ];
                format = "iso";
              };
            }) (nixpkgs.lib.filter ({ edition, arch }: 
              getSystem arch == system
            ) combinations)
          )) // {
            # Default package for Linux
            default = nixos-generators.nixosGenerate {
              inherit system;
              modules = [
                ./modules/swl-edition.nix
                ./hardware/x86-minimal.nix
                ./images/base-image.nix
                {
                  isoImage.isoName = "ham-radio-swl-x86.iso";
                }
              ];
              format = "iso";
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
                echo "🎯 HAM Radio NixOS Development Environment"
                echo "📡 Available editions: ${builtins.concatStringsSep ", " editions}"
                echo "💻 Available architectures: ${builtins.concatStringsSep ", " architectures}"
                echo ""
                echo "🚀 To build ISOs (requires Linux):"
                echo "   nix build .#swl-x86-iso"
                echo "   nix build .#digimodes-rpi-iso"
                echo ""
                echo "🔧 To test configurations:"
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
              echo "🎯 HAM Radio NixOS Development Environment"
              echo "📡 Available editions: ${builtins.concatStringsSep ", " editions}"
              echo "💻 Available architectures: ${builtins.concatStringsSep ", " architectures}"
              echo ""
              ${if isLinux then ''
                echo "🚀 Build commands:"
                echo "   nix build .#swl-x86-iso"
                echo "   nix build .#digimodes-rpi-iso"
                echo ""
                echo "🔧 Test commands:"
                echo "   nixos-rebuild build-vm --flake .#swl-x86"
              '' else ''
                echo "🍎 Running on macOS - use remote Linux builder for ISO builds:"
                echo "   nix build .#swl-x86-iso --builders 'ssh://user@linux-machine x86_64-linux'"
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