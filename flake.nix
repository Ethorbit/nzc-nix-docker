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

# TODO:
# Each subdir in projects/ will have its own Dockerfiles, data, and Arion configuration
# Admins will `git clone` this flake and setup the shared variables (basically nix instead of .env)
# Admins will run arion off the devShell: `nix develop`
# Admins will use arion to deploy the projects they want to run on their node
#   > arion -f ./projects/<name> -f /path/to/custom/configuration up

{
    description = ''Library for nZC game community's Dockerized server infrastructure'';

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
        flake-utils.url = "github:numtide/flake-utils";
        arion.url = "github:hercules-ci/arion/3534dd9d0f32c7dbee4f87378d4c95ffcd8838c5";
    };

    outputs = {
        self,
        nixpkgs,
        arion,
        flake-utils
    }: let
        projects = ./projects;
    in {
        inherit projects;
    
        lib.mkDeployment = { instances, pkgs, system }: let
            arion = self.arion.${system};
            instanceApps = builtins.mapAttrs (name: inst:
                let
                    project = self.projects + "/${inst.project}";
                    composed = arion.eval {
                        modules = [
                            (project + "/default.nix")
                            { nzc.instance = inst.instance // { inherit name; }; }
                        ];
                        inherit pkgs;
                    };
                    script = pkgs.writeShellApplication {
                        name = name;
                        runtimeInputs = [ arion.package ];
                        text = ''
                            arion --prebuilt-file "${composed.config.out.dockerComposeYaml}" "$@"
                        '';
                    };
                in {
                    type = "app";
                    program = "${script}/bin/${name}";
                }
            ) instances;
            projectGroups = builtins.foldl' (acc: name:
                let project = instances.${name}.project;
                in acc // {
                    ${project} = (acc.${project} or []) ++ [ name ];
                }
            ) {} (builtins.attrNames instances);
            projectApps = builtins.mapAttrs (project: names:
                let
                    safeName = builtins.replaceStrings ["/"] ["-"] project;
                    script = pkgs.writeShellApplication {
                        name = safeName;
                        text = builtins.concatStringsSep "\n" (
                            map (name: ''
                                ${instanceApps.${name}.program} "$@"
                            '') names
                        );
                    };
                in {
                    type = "app";
                    program = "${script}/bin/${safeName}";
                }
            ) projectGroups;
            allApps = let
                script = pkgs.writeShellApplication {
                    name = "all";
                    text = builtins.concatStringsSep "\n" (
                        map (name: ''
                            ${instanceApps.${name}.program} "$@"
                        '') (builtins.attrNames instances)
                    );
                };
            in {
                type = "app";
                program = "${script}/bin/all";
            };
        in {
            apps = instanceApps // projectApps // { all = allApps; };
        };
    } // flake-utils.lib.eachDefaultSystem (system: let
        pkgs = import nixpkgs {
            inherit system;
        };

        patchedArionSrc = pkgs.applyPatches {
            src = arion.packages.${system}.arion.src;
            patches = [ ./patches/docker-compose-service.nix.patch ];
        };

        patchedArion = (arion.packages.${system}.arion.overrideAttrs (old: {
            patches = [ ./patches/docker-compose-service.nix.patch ];
        }));
    in with pkgs; {
        arion = {
            package = patchedArion;
            eval = import "${patchedArionSrc}/src/nix/eval-composition.nix";
        };

        devShells.default = mkShell {
            buildInputs = [
                patchedArion
            ];
        };
    });
}
