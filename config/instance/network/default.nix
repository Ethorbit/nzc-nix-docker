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
                    default = [];
                    example = [
                        {
                            host = 27016;
                            container = 27015;
                            protocol = "tcp";
                        }
                    ];
                    type = types.listOf (types.submodule {
                        options = {
                            host = mkOption {
                                description = ''Host port to bind'';
                                type = types.int;
                                example = 27016;
                            };

                            container = mkOption {
                                description = ''Container port to expose'';
                                type = types.int;
                                example = 27015;
                            };

                            protocol = mkOption {
                                description = ''Protocol for this port mapping'';
                                type = types.enum [ "tcp" "udp" ];
                                default = "tcp";
                                example = "udp";
                            };
                        };
                    });
                };
            };
        };
        default = {};
        example = import ./example.nix;
    };
}
