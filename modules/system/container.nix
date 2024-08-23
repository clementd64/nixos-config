{ config, lib, pkgs, ... }:

# (almost) declaratively manage imperative nixos-containers
# Need to be bootstrapped (to add profile to nix store) with
#   sudo nixos-container update hostname --flake github:clementd64/nixos-config#hostname
# rootfs in /var/lib/nixos-containers is generated when started, so tmpfs as root setup is possible

with lib; let
  cfg = config.clement.containers;
in {
  options.clement.containers = {
    enable = mkEnableOption "containers";

    network = {
      enable = mkEnableOption "containers networking";

      bridge = mkOption {
        type = types.str;
        default = "br-ctr";
      };

      address = {
        ipv4 = mkOption { type = types.nullOr types.str; default = "172.16.0.254/24"; };
        ipv6 = mkOption { type = types.nullOr types.str; default = null; };
      };

      nat = mkOption {
        type = with types; either bool (enum [ "ipv4" "ipv6" ]);
        default = "ipv4";
      };

      routes = mkOption {
        type = types.listOf (types.submodule {
          options = {
            destination = mkOption { type = types.str; };
            gateway = mkOption { type = types.str; };
          };
        });
        default = [];
      };
    };

    containers = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          autoStart = mkOption {
            type = types.bool;
            default = false;
          };

          persistDir = mkOption {
            type = types.bool;
            default = false;
          };
        };
      });
    };
  };

  options.containers = mkOption {
    type = types.attrsOf (types.submodule ({ config, ... }: {
      options.allowDocker = mkOption {
        type = types.bool;
        default = false;
      };

      config = mkMerge [
        {
          config = { ... }: {
            imports = (import ../../modules).system;
            config.nixpkgs.overlays = [
              (import ../../overlays/pkgs.nix)
              (import ../../overlays/lib.nix)
            ];
          };
          extraFlags = optionals config.allowDocker (builtins.map (x: "--system-call-filter=${x}") ["add_key" "keyctl" "bpf"]);
        }
        (let
          mkHostAddress = host: local: mkIf (host != null && local != null) (mkDefault (builtins.head (splitString "/" host)));
        in mkIf cfg.network.enable {
          privateNetwork = mkDefault true;
          hostBridge = mkDefault cfg.network.bridge;
          hostAddress = mkHostAddress cfg.network.address.ipv4 config.localAddress;
          hostAddress6 = mkHostAddress cfg.network.address.ipv6 config.localAddress6;
        })
      ];
    }));
  };

  config = mkMerge [
    (mkIf cfg.network.enable {
      systemd.network = {
        netdevs."20-${cfg.network.bridge}" = {
          netdevConfig = {
            Kind = "bridge";
            Name = cfg.network.bridge;
          };
        };

        networks."20-${cfg.network.bridge}" = {
          matchConfig.Name = cfg.network.bridge;
          # TODO(24.11): cleanup
          networkConfig = {
            Address = optional (cfg.network.address.ipv4 != null) cfg.network.address.ipv4
              ++ optional (cfg.network.address.ipv6 != null) cfg.network.address.ipv6;
          } // (if versionAtLeast config.system.nixos.release "24.11" then {
            IPv4Forwarding = true;
            IPv6Forwarding = true;
          } else {
            IPForward = true;
          });
          linkConfig.RequiredForOnline = "no";

          # TODO(24.11): cleanup
          routes =
            let
              mkRoute = Destination: Gateway:
                if versionAtLeast config.system.nixos.release "24.11"
                then { inherit Destination Gateway; }
                else { routeConfig = { inherit Destination Gateway; }; };
            in builtins.map (x: mkRoute x.destination x.gateway) cfg.network.routes;
        };
      };

      networking.nat = {
        enable = cfg.network.nat != false;
        enableIPv6 = cfg.network.nat == true || cfg.network.nat == "ipv6";
        extraCommands = optionalString (cfg.network.nat == true || cfg.network.nat == "ipv4") ''
          iptables -t nat -A nixos-nat-post -s ${cfg.network.address.ipv4} ! -o ${cfg.network.bridge} -j MASQUERADE
        '' + optionalString (cfg.network.nat == true || cfg.network.nat == "ipv6") ''
          ip6tables -t nat -A nixos-nat-post -s ${cfg.network.address.ipv6} ! -o ${cfg.network.bridge} -j MASQUERADE
        '';
      };
    })

    (mkIf cfg.enable {
      clement.containers.network.enable = true;

      environment.etc = attrsets.mapAttrs' (name: value: {
        name = "nixos-containers/${name}.conf";
        value = {
          text = strings.concatStringsSep "\n" (
            [
              "PRIVATE_NETWORK=1"
              "HOST_BRIDGE=${cfg.network.bridge}"
            ]
            ++ optional value.persistDir "EXTRA_NSPAWN_FLAGS=--bind=/nix/persist/nixos-containers/${name}:/nix/persist"
          );
        };
      }) cfg.containers;

      systemd.nspawn = builtins.mapAttrs (name: value: {
        # Allow running OCI containers
        execConfig.SystemCallFilter = [ "add_key" "keyctl" "bpf" ];
      }) cfg.containers;

      # Start on boot
      systemd.targets.machines.wants = attrsets.mapAttrsToList (n: v: "container@${n}.service")
          (filterAttrs (n: v: v.autoStart) cfg.containers);

      # Create required directories
      systemd.tmpfiles.rules = lists.flatten (attrsets.mapAttrsToList (name: value:
        ["d /nix/var/nix/profiles/per-container/${name} - root root - -"]
        ++ optional value.persistDir "d /nix/persist/nixos-containers/${name} - root root - -"
      ) cfg.containers);
    })
  ];
}