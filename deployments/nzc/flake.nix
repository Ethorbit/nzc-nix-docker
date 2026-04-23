# LICENSE HEADER MANAGED BY add-license-header
#
# Copyright (C) 2026 Ethorbit
#
# This file is part of nZC.
#
# nZC is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 3
# of the License, or (at your option) any later version.
#
# nZC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the
# GNU General Public License along with nZC.
# If not, see <https://www.gnu.org/licenses/>.
#

{
    description = ''nZC game community's Dockerized server infrastructure'';

    inputs = {
        nzc-nix-docker.url = "github:Ethorbit/nzc-nix-docker";
        nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = {
        self,
        nixpkgs,
        nzc-nix-docker,
        flake-utils
    }: flake-utils.lib.eachDefaultSystem (system: let
        pkgs = import nixpkgs {
            inherit system;
        };

        cfg = import ./config/default.nix { inherit (pkgs) lib; };
        instances = cfg.config.instances;
        arion = nzc-nix-docker.arion.${system};

        programs = with pkgs; {
            list = writeShellApplication {
                name = "list";
                text = ''
                    set -e
                    echo "${builtins.concatStringsSep "\n" (
                        builtins.attrNames instances
                    )}"
                '';
            };

            arion-program = writeShellApplication {
                name = "arion";
                runtimeInputs = [ arion.package ];
                text = ''
                    instance=""
                    if [ "''${1:-}" = "-i" ]; then
                        instance="''${2}"
                        shift 2
                    fi

                    ${builtins.concatStringsSep "\n" (
                        map (name:
                            let
                                inst = instances.${name};
                                project = nzc-nix-docker.projects + "/${inst.project}";
                                composed = nzc-nix-docker.arion.${system}.eval {
                                    modules = [
                                        (project + "/default.nix")
                                        { nzc.instance = inst.instance; }
                                    ];
                                    inherit pkgs;
                                };
                            in ''
                                if [ -z "$instance" ] || [ "$instance" = "${name}" ]; then
                                    echo "${name}"
                                    arion --prebuilt-file "${composed.config.out.dockerComposeYaml}" "$@"
                                fi
                            ''
                        ) (builtins.attrNames instances)
                    )}
                '';
            };
        };
    in {
        apps = with programs; {
            list = {
                type = "app";
                program = "${list}/bin/list";
            };

            arion = {
                type = "app";
                program = "${arion-program}/bin/arion";
            };
        };
    });
}
