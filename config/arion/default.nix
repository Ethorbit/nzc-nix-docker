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

{ lib, ... }:
with lib;
{
    imports = [
        ./project
        ./service
        ./docker-compose
    ];

    options = {
        nzc.arion.defaults = mkOption {
            description = ''nZC Arion configuration to simplify project development'';
        };

        nzc.arion.presets = mkOption {
            description = ''nZC Arion configuration to simplify project development'';
        };

        nzc.arion.eval = lib.mkOption {
            type = lib.types.raw;   # or lib.types.unspecified if raw isn't available in your nixpkgs version
            description = "Reference to arion's eval-composition function, for nested project evaluation.";
        };
    };
}
