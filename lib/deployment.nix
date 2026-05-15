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

{ self }:
    { instances, pkgs, system }: let
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
    }
