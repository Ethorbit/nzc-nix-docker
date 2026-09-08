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
    volumes = instance.storage.volumes;
    secrets = instance.secrets;
    features = instance.features;
    dockerTags = instance.docker.tags;

    uid = instance.user.uid;
    gid = instance.user.gid;

    mysqlConfig = {
        user = instance.mysql.config;
        default = ./app-config/mysql.cnf;
    };

    exists = {
        "dockerTags.mysql" = dockerTags ? "mysql";
        #"dockerTags.backups" = dockerTags ? "backups";
        #"dockerTags.phpmyadmin" = dockerTags ? "phpmyadmin";
        #"dockerTags.nginx" = dockerTags ? "nginx";
        "ssl.certificate" = secrets ? "ssl.certificate";
        "ssl.key"  = secrets ? "ssl.key";
    };

    dockerfiles = {
        mysql = (pkgs.callPackage ./dockerfile/mysql ({
            PUID = toString uid;
            PGID = toString gid;
        } // (lib.optionalAttrs exists."dockerTags.mysql" {
            IMAGE_TAG = dockerTags."mysql";
        })));
    };
    #// (lib.optionalAttrs features.phpmyadmin.enabled {
    #    phpmyadmin = (pkgs.callPackage ./dockerfile/phpmyadmin ({
    #        PUID = toString uid;
    #        PGID = toString gid;
    #    } // (lib.optionalAttrs exists."ssl.certificate" {
    #        SSL_CERT = secrets."ssl.certificate";
    #        SSL_KEY = secrets."ssl.key";
    #    }) // (lib.optionalAttrs exists."dockerTags.phpmyadmin" {
    #        IMAGE_TAG = dockerTags."phpmyadmin";
    #    })));
    #}) // {
    #    nginx = (pkgs.callPackage ./dockerfile/nginx ({
    #        PUID = toString uid;
    #        PGID = toString gid;
    #    } // (lib.optionalAttrs exists."dockerTags.nginx") {
    #        IMAGE_TAG = dockerTags."nginx";
    #    }));
    #};
in
{
    imports = [
        ../../config
        ./options.nix
    ];

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

            #storage.volumes = [
            #    {
            #        id = "websites";
            #        required = true;
            #    }
            #];

            docker.tags = [ "mysql" "nginx" "phpmyadmin" ];
        };

        warnings = 
            lib.optional 
                (mysqlConfig.user == mysqlConfig.default)
                ''mysql.config wasn't set, using a default mysql.cnf file.'';

        assertions = [
            {
                assertion = exists."ssl.certificate" == exists."ssl.key";
                message = "ssl.certificate and ssl.key must either both be defined or both be undefined.";
            }
        ];

        project = defaults.project;

        services = with lib; {
            mysql.service = defaults.service // {
                build.context = "${dockerfiles.mysql}";
                volumes = [
                    "${secrets."admin.password"}:/run/secrets/admin-password:ro"
                    "${mysqlConfig.user}:/etc/mysql/conf.d/mysql.cnf"
                ];
                environment = {
                    MYSQL_ROOT_PASSWORD_FILE = "/run/secrets/admin-password";
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
            };
        }
        // (lib.optionalAttrs features.backups.enabled {

        })
        // (lib.optionalAttrs features.phpmyadmin.enabled {
        
        });
    };
}
