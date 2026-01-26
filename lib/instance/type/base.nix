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
                    type = types.listOf (types.submodule {
                        options = {
                            host = mkOption {
                                type = types.str;
                                example = "/srv/websites";
                            };

                            container = mkOption {
                                type = types.path;
                                example = "/var/www/html";
                            };

                            readonly = mkOption {
                                description = "True to prevent container from modifying files in the mount.";
                                type = types.bool;
                                default = false;
                                example = true;
                            };
                        };
                    });
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
                            cpuset = mkOption {
                                type = types.listOf types.int;
                                description = "CPU cores allowed";
                                default = [];
                                example = [ 0 1 2 ];
                            };

                            cpuFraction = mkOption {
                                type = types.float;
                                description = "Number of CPU shares";
                                default = 1.0;
                                example = 0.5;
                            };

                            ram = mkOption {
                                type = types.int;
                                description = "RAM limit in MB";
                                example = 256;
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
                        cpuset = [ 0 1 2 ];
                        cpuFraction = 0.8;
                        ram = 512;
                        bandwidth = 25;
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
                cpuset = [ 0 ];
                cpuFraction = 1.0;
                ram = 1024;
                bandwidth = 30;
            };
        };
    };
}
