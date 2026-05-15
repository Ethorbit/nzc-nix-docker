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
 
        lib = {
            mkDeployment = import ./lib/deployment.nix { inherit self; };
            allocation.threadOf = import ./lib/allocation/threadOf.nix;
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
        apps = let 
            testDeployment = self.lib.mkDeployment {
                inherit pkgs system;
                instances."example" = {
                    project = "example";
                    instance = {
                        user = {
                            uid = 1000;
                            gid = 1000;
                        };
                    };
                };
            };
        in testDeployment.apps;

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
