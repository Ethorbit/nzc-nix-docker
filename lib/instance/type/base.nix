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

{ lib }:

with lib;

let
    imported.types = {
        volume = import ./volume.nix { inherit lib; };
    };
in
{
    options.instance = mkOption {
        description = ''nZC Container instance'';

        type = types.submodule {
            options = {
                name = mkOption {
                    type = types.str;
                    default = null;
                    description = "Unique instance name";
                    example = "my-cool-container";
                };

                user = mkOption {
                    type = types.submodule {
                        options = {
                            uid = mkOption {
                                description = "User ID the main process will run under.";
                                type = types.int;
                                default = 0;
                                example = 1000;
                            };

                            gid = mkOption {
                                description = "Group ID the main process will run under.";
                                type = types.int;
                                default = 0;
                                example = 1000;
                            };
                        };
                    };
                };

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

                resources = mkOption {
                    description = ''Resource limits for container'';
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
                                };
                            };
                            
                            memory = mkOption {
                                description = "Memory limits for the container";
                                type = types.submodule {
                                    options = {
                                        limit = mkOption {
                                            description = "Memory limit in megabytes (MB)";
                                            type = types.int;
                                            default = 4000;
                                            example = 256;
                                        };
                                    };
                                };
                                default = {};
                                example = {
                                    limit = 500;
                                };
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
                        memory.limit = 500;
                        bandwidth = 25;
                    };
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
                                type = types.listOf (imported.types.volume);
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

        example = {
            name = "my-example-container";
            user = {
                uid = 1001;
                gid = 1001;
            };
            ports = [
                {
                    host = "443";
                    container = "2443";
                    protocol = "tcp";
                }
            ];
            volumes = [
                {
                    host = "/srv/container_config";
                    container = "/home/service/config";
                    readonly = true;
                }
            ];
            resources = {
                cpu = {
                    cores = [ 0 ];
                    quota = 1.0;
                    weight = 1024;
                };
                memory.limit = 1000;
                bandwidth = 30;
            };
        };
    };
}
