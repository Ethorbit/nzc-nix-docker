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

{ config, lib, pkgs, ... }:

let
    defaults = config.nzc.arion.defaults;
    instance = config.nzc.instance;
    secrets = instance.secrets;
    dockerTags = instance.docker.tags;

    uid = instance.user.uid;
    gid = instance.user.gid;

    mysqlConfig = {
        user = instance.mysql.config;
        default = ./mysql.cnf;
    };

    tagExists = dockerTags ? "mysql";

    dockerfile = (pkgs.callPackage ./dockerfile ({
        PUID = toString uid;
        PGID = toString gid;
    } // (lib.optionalAttrs tagExists {
        IMAGE_TAG = dockerTags."mysql";
    })));
in
{
    imports = [
        ../../config
        ./features/phpmyadmin
        ./features/backups
    ];

    options = with lib; {
        nzc = {
            instance = {
                mysql = {
                    adminName = mkOption {
                        description = "The MySQL admin username.";
                        type = types.string;
                        default = "admin";
                    };

                    config = mkOption {
                        description = "Path to a custom mysql.cnf configuration file.";
                        type = types.path;
                        default = ./mysql.cnf;
                    };
                };
            };
        };
    };

    config = {
        nzc.project = {
            features = [ "backups" "phpmyadmin" ];

            network.ports = [
                {
                    id = "mysql";
                    required = true;
                }
            ];

            secrets = [
                {
                    id = "root.password";
                    required = true;
                }
                {
                    id = "admin.password";
                    required = true;
                }
                {
                    id = "ssl.certificate";
                    required = false;
                }
                {
                    id = "ssl.key";
                    required = false;
                }
            ];

            docker.tags = [ "mysql" ];
        };

        warnings = 
            lib.optional 
                (mysqlConfig.user == mysqlConfig.default)
                ''mysql.config wasn't set, using a default mysql.cnf file.'';

        project = defaults.project;
        docker-compose = defaults.docker-compose;

        networks = {
            mysql = {};
        };

        services = with lib; {
            mysql.service = defaults.service // {
                build.context = "${dockerfile}";
                volumes = [
                    "${secrets."root.password"}:/run/secrets/root-password:ro"
                    "${secrets."admin.password"}:/run/secrets/admin-password:ro"
                    "${mysqlConfig.user}:/etc/mysql/conf.d/mysql.cnf"
                ];
                environment = {
                    MYSQL_ADMIN_NAME = instance.mysql.adminName;
                    MYSQL_ADMIN_PASSWORD_FILE = "/run/secrets/admin-password";
                    MYSQL_ROOT_PASSWORD_FILE = "/run/secrets/root-password";
                };
                ports = let
                    bind = config.nzc.project.network.bindPortTo;
                in [
                    (bind "mysql" "tcp" 3306)
                ];
                ulimits = {
                    nproc = mkDefault 65535;
                    nofile = {
                        hard = mkDefault 40000;
                        soft = mkDefault 20000;
                    };
                };
                healthcheck = {
                    test = [
                        "CMD"
                        "mysqladmin ping -h 127.0.0.1 --silent || exit 1"
                    ];
                    start_period = "5s";
                    interval = "5s";
                    timeout = "10s";
                    retries = 3;
                };
                restart = mkDefault "always";
                networks = [ "mysql" ];
            };
        };
    };
}
