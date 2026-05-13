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
                    type = types.attrsOf (types.submodule {
                        options = {
                            number = mkOption {
                                description = "The number this port represents.";
                                example = 22;
                                type = types.port;
                            };

                            ip = mkOption {
                                description = "Optionally set an IP for this port.";
                                type = types.submodule {
                                    options = {
                                        tcp = mkOption {
                                            type = types.nullOr types.str;
                                            description = "IP this TCP port is exposed to.";
                                            example = "127.0.0.1";
                                            default = null;
                                        };
                                        udp = mkOption {
                                            type = types.nullOr types.str;
                                            description = "IP this UDP port is exposed to.";
                                            example = "192.168.254.18";
                                            default = null;
                                        };
                                    };
                                };
                                default = {};
                            };
                        };
                    });
                    default = {};
                    example = {
                        gmod = { ip.udp = "0.0.0.0"; port = 27016; };
                    };
                };
            };
        };
        default = {};
        example = import ./example.nix;
    };
}
