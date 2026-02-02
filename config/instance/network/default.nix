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
        ./endpoints
    ];

    options.nzc.instance.network = mkOption {
        description = ''Network settings for instance'';
        type = types.submodule {
            options = {
                ports = mkOption {
                    description = ''Network ports for container'';
                    type = types.attrsOf types.int;
                    default = {};
                    example = {
                        gmod = 27016;
                    };
                };
            };
        };
        default = {};
        example = import ./example.nix;
    };
}
