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

let
    imported.types.disk = import ./type/disk.nix { inherit lib; };
in
{
    options.nzc.instance.limit = mkOption {
        description = ''Resource limits for instance'';
        type = types.submodule {
            options = {
                enable = mkOption {
                    description = "Configure resource limits for the container";
                    type = types.bool;
                    default = true;
                };

                cpu = mkOption {
                    description = "CPU limits for the container";
                    type = types.submodule {
                        options = {
                            cores = mkOption {
                                type = types.listOf types.int;
                                description = "CPU cores available to the container";
                                default = [];
                                example = [ 0 1 2 ];
                            };

                            quota = mkOption {
                                type = types.addCheck types.float (
                                    x: x >= 0.0
                                );
                                description = "Total number of cores we're allowed to utilize";
                                default = 100.0;
                                example = 0.5;
                            };

                            weight = mkOption {
                                type = types.int;
                                description = "During contention, how much CPU time relative to other containers should this get";
                                default = 1024;
                                example = 512;
                            };
                        };
                    };
                    example = {
                        cores = [
                            0 1 2 3
                        ];
                        quota = 2.5;
                        weight = 1024;
                    };
                };
                
                memory = mkOption {
                    description = "Memory limit for the container (in megabytes [MB])";
                    type = types.int;
                    default = 4000;
                    example = 256;
                };

                disk = mkOption {
                    description = "Disk limits";
                    type = types.listOf (types.submodule {
                        options = {
                            device = mkOption {
                                description = "The storage device file";
                                type = types.strMatching "^/dev/.*";
                                example = "/dev/sda";
                            };

                            read = mkOption {
                                description = "Read limits";
                                type = imported.types.disk;
                                default = {};
                            };

                            write = mkOption {
                                description = "Write limits";
                                type = imported.types.disk;
                                default = {};
                            };
                        };
                    });
                    example = [
                        {
                            device = "/dev/sda";
                            write = {
                                iops = 5000;
                                speed = 500;
                            };
                            read = {
                                iops = 50000;
                                speed = 2000;
                            };
                        }
                    ];
                    default = [];
                };

                bandwidth = mkOption {
                    type = types.int;
                    description = "Network bandwidth limit in Mbps";
                    default = 100;
                    example = 15;
                };
            };
        };
        default = {};
        example = {
            cpu = {
                cores = [ 0 1 2 ];
                quota = 0.8;
                weight = 1024;
            };
            memory = 500;
            disk.write = [
                {
                    device = "/dev/sda";
                    speed = 75;
                    iops = 15000;
                }
            ];
            bandwidth = 25;
        };
    };
}
