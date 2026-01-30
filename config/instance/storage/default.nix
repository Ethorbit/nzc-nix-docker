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
    imported.types = {
        volume = import ./type/volume { inherit lib; };
        lxcfs-volume = import ./type/volume/lxcfs.nix { inherit lib; };
    };
in
{
    options.nzc.instance.storage = mkOption {
        description = ''Storage settings for instance'';
        type = types.submodule {
            options = {
                volumes = mkOption {
                    description = ''List of storage volumes for the container'';
                    type = types.listOf (imported.types.volume);
                    default = [];
                    example = [
                        {
                            host = "/var/lib/app-cache";
                            container = "/cache";
                        }
                        {
                            host = "/var/lib/app-state";
                            container = "/state";
                            readonly = false;
                        }
                        {
                            host = "/var/lib/app-ca";
                            container = "/etc/ssl/custom-ca";
                            readonly = true;
                        }
                    ];
                };

                lxcfs = mkOption {
                    description = ''
                        We use lxcfs so that the containerized programs can see the container's resources rather 
                        than the host's resources, which helps with performance.

                        If you don't care and don't want to use lxcfs, you can just turn this off.

                        Make sure lxcfs is running:
                        sudo systemctl enable lxcfs --now

                        find /var/lib/lxcfs/ You should be seeing many files listed for things like cpu and whatnot 
                    '';
                    type = types.submodule {
                        options = {
                            enable = mkOption {
                                description = ''Will this container use lxcfs?'';
                                default = true;
                                example = false;
                            };

                            volumes = mkOption {
                                description = ''The lxcfs paths that will be passed to containers'';
                                type = types.listOf (imported.types.lxcfs-volume);
                                default = [
                                    {
                                        host = "/var/lib/lxcfs/sys/devices/system/cpu/online";
                                        container = "/sys/devices/system/cpu/online";
                                        readonly = true;
                                    }
                                    {
                                        host = "/var/lib/lxcfs/proc/swaps";
                                        container = "/proc/swaps";
                                        readonly = true;
                                    }
                                    {
                                        host = "/var/lib/lxcfs/proc/cpuinfo";
                                        container = "/proc/cpuinfo";
                                        readonly = true;
                                    }
                                    {
                                        host = "/var/lib/lxcfs/proc/stat";
                                        container = "/proc/stat";
                                        readonly = true;
                                    }
                                    {
                                        host = "/var/lib/lxcfs/proc/meminfo";
                                        container = "/proc/meminfo";
                                        readonly = true;
                                    }
                                    {
                                        host = "/var/lib/lxcfs/proc/diskstats";
                                        container = "/proc/diskstats";
                                        readonly = true;
                                    }
                                    {
                                        host = "/var/lib/lxcfs/proc/uptime";
                                        container = "/proc/uptime";
                                        readonly = true;
                                    }
                                ];
                            };
                        };
                    };
                    default = {};
                    example = {
                        enable = true;
                        mounts = [
                            {
                                host = "/var/lib/lxcfs/proc/meminfo";
                                container = "/proc/meminfo";
                                readonly = true;
                            }
                        ];
                    };
                };
            };
        };
        default = {};
        example = {
            volumes = [
                {
                    host = "/var/lib/app-cache";
                    container = "/cache";
                }
                {
                    host = "/var/lib/app-state";
                    container = "/state";
                    readonly = false;
                }
                {
                    host = "/var/lib/app-ca";
                    container = "/etc/ssl/custom-ca";
                    readonly = true;
                }
            ];
        };
    };
}
