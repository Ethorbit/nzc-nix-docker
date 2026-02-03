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

{ config, lib, ... }:

with lib;

{
    options.nzc.project.network.ports = mkOption {
        description = ''The container ports required by this project'';
        type = types.listOf (types.submodule {
            options = {
                id = mkOption {
                    description = ''Identifier of this port'';
                    type = types.str;
                    example = "website";
                };

                required = mkOption {
                    description = ''
                        Whether or not this port is required for a project to function
                    '';
                    type = types.bool;
                    default = false;
                };
            };
        });
        default = [];
        example = [
            {
                id = "website";
                required = false;
            }
        ];
    };

    config.nzc.project.checks = [
        {
            name = "network.ports";
            official = config.nzc.project.network.ports;
            user = config.nzc.instance.network.ports;
        }
    ];
}
