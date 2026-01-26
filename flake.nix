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
    description = ''nZC game community's Dockerized server infrastructure'';

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
    }: flake-utils.lib.eachDefaultSystem (system: let
        pkgs = import nixpkgs {
            inherit system;
        };
    in with pkgs; {
        devShells.default = mkShell {
            buildInputs = [
                (arion.packages.${system}.arion.overrideAttrs (old: {
                    patches = [ ./patches/docker-compose-service.nix.patch ];
                }))
            ];
        };
    });
}
