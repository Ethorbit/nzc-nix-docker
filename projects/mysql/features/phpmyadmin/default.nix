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

{ pkgs, lib, config, ... }:

let
    defaults = config.nzc.arion.defaults;
    instance = config.nzc.instance;
    secrets = instance.secrets;
    features = instance.features;
    dockerTags = instance.docker.tags;

    uid = instance.user.uid;
    gid = instance.user.gid;

    phpmyadminConfig = rec {
        defaultSettings = {
            PMA_HOST = "127.0.0.1";
            MYSQL_USER = "root";
        };
        user = instance.phpmyadmin.config;
        default = pkgs.callPackage ./config.inc.php.nix defaultSettings;
    };

    exists = {
        "dockerTags.phpmyadmin" = dockerTags ? "phpmyadmin";
        "dockerTags.nginx" = dockerTags ? "nginx";
        "ssl.certificate" = secrets ? "ssl.certificate";
        "ssl.key"  = secrets ? "ssl.key";
    };

    dockerfiles = (lib.optionalAttrs features.phpmyadmin.enabled {
        phpmyadmin = (pkgs.callPackage ./dockerfile/phpmyadmin ({
            PUID = toString uid;
            PGID = toString gid;
        } // (lib.optionalAttrs exists."dockerTags.phpmyadmin" {
            IMAGE_TAG = dockerTags."phpmyadmin";
        })));

        # nginx = (pkgs.callPackage ./dockerfile/nginx ({
        #     PUID = toString uid;
        #     PGID = toString gid;
        # } // (lib.optionalAttrs exists."dockerTags.nginx") {
        #     IMAGE_TAG = dockerTags."nginx";
        # } // (lib.optionalAttrs exists."ssl.certificate" {
        #     SSL_CERT = secrets."ssl.certificate";
        #     SSL_KEY = secrets."ssl.key";
        # })));
    });
in
{
    options = with lib; {
        nzc.instance = {
            phpmyadmin = {
                config = mkOption {
                    type = types.path;
                    default = pkgs.callPackage 
                        ./config.inc.php.nix phpmyadminConfig.defaultSettings;
                };
            };
        };
    };

    config = lib.mkIf features.phpmyadmin.enabled {
        warnings = 
            lib.optional 
                (phpmyadminConfig.user == phpmyadminConfig.default)
                ''phpmyadmin.config wasn't set, using a default config.inc.php file.'';

        assertions = [
            {
                assertion = exists."ssl.certificate" == exists."ssl.key";
                message = "ssl.certificate and ssl.key must either both be defined or both be undefined.";
            }
        ];

        nzc.project = {
            secrets = [
                {
                    id = "phpmyadmin.blowfish";
                    required = true;
                }
            ];
        
            docker.tags = [ "phpmyadmin" ];
        };

        docker-compose.volumes."phpmyadmin" = {};

        services = with lib; {
            phpmyadmin-permissions.service = config.nzc.arion.presets.service.permissions // {
                volumes = [
                    "phpmyadmin:/mnt/panel"
                ];
            };

            phpmyadmin.service = defaults.service // {
                build.context = "${dockerfiles.phpmyadmin}";
                volumes = [
                    "${phpmyadminConfig.user}:/var/www/html/config.inc.php:ro"
                    "${secrets."admin.password"}:/run/secrets/mysql-password:ro"
                    "${secrets."phpmyadmin.blowfish"}:/run/secrets/phpmyadmin-blowfishsecret:ro"
                    "phpmyadmin:/panel"
                ];
                depends_on.phpmyadmin-permissions.condition = "service_completed_successfully";
                restart = mkDefault "on-failure";
            };
        };
    };
}
