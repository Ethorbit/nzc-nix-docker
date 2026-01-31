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
    options.nzc.instance.network.endpoints = mkOption {
        description = ''Endpoints the container can connect and communicate with'';
        type = types.listOf (types.submodule {
            options = {
                id = mkOption {
                    description = ''Identifier of this endpoint'';  
                    type = types.str;
                    example = "gmod";
                };

                host = mkOption {
                    type = types.submodule {
                        options = {
                            type = mkOption {
                                description = ''
                                The type of endpoint host represents

                                "container" would mean host refers to a name of a container running on the host
                                "address" would mean the IP or domain to reach the service (container / not container)
                                '';
                                type = types.enum [ "container" "address" ];
                                default = "container";
                            };

                            value = mkOption {
                                description = ''Hostname or container name of the endpoint'';
                                type = types.str;
                                example = "my-gmod-container";
                            };
                        };
                    };
                    
                    example = {
                        type = "container";
                        value = "my-gmod-container";
                    };
                };

                port = mkOption {
                    description = ''Port number for this endpoint'';
                    type = types.int;
                    example = 27015;
                };
            };
        });
        default = [];
        example = [
            {
                id = "gmod";
                host = {
                    type = "container";
                    value = "my-gmod-container";
                };
                port = 27015;
            }
        ];
    };
}
