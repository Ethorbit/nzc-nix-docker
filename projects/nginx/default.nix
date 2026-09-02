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

    nginxConfig = {
        default = ./app-config/nginx.conf; 
        user = instance.nginx.config;
    };

    phpConfig = {
        www = {
            default = ./app-config/php-fpm/www.conf;
            user = instance.php-fpm.config.www;
        };

        ini = {
            default = (pkgs.callPackage ./app-config/php-fpm/php.ini.nix {
                phpSettings = instance.php-fpm;
            });
            user = instance.php-fpm.config.ini;
        };
    };

    uid = instance.user.uid;
    gid = instance.user.gid;

    exists = {
        "ssl.certificate" = secrets ? "ssl.certificate";
        "ssl.key"  = secrets ? "ssl.key";
    };

    dockerfiles = {
        nginx = pkgs.callPackage ./dockerfile/nginx {
            PUID = toString uid;
            PGID = toString gid;
        } // lib.optionalAttrs exists."ssl.certificate" {
            SSL_CERT = secrets."ssl.certificate";
            SSL_KEY = secrets."ssl.key";
        };
    } // (lib.optionalAttrs features.php.enabled {
        php-fpm = pkgs.callPackage ./dockerfile/php-fpm {
            PUID = toString uid;
            PGID = toString gid;
            phpSettings = instance.php-fpm;
        };
    });
in
{
    imports = [
        ../../config
        ./options.nix
    ];

    config = {
        nzc.project = {
            features = [
                "php"
            ];

            network.ports = [
                {
                    id = "http";
                    required = true;
                }
                {
                    id = "https";
                    required = true;
                }
            ];

            secrets = [
                {
                    id = "ssl.certificate";
                    required = false;
                }
                {
                    id = "ssl.key";
                    required = false;
                }
            ];

            storage.volumes = [
                {
                    id = "websites";
                    required = true;
                }
            ];
        };

        assertions = [
            {
                assertion = exists."ssl.certificate" == exists."ssl.key";
                message = "ssl.certificate and ssl.key must either both be defined or both be undefined.";
            }
        ];

        warnings =
            lib.optional
                (nginxConfig.user == nginxConfig.default)
                ''
                nginx.config is at its default value.
                ''
            ++ lib.optional (features.php.enabled && phpConfig.www.user == phpConfig.www.default)
                ''
                php-fpm.config.www is at its default value.
                ''
            ++ lib.optional (features.php.enabled && phpConfig.ini.user == phpConfig.ini.default)
                ''
                php-fpm.config.ini is at its default value.
                '';

        project = defaults.project;
        docker-compose = defaults.docker-compose //
            lib.optionalAttrs features.php.enabled {
                volumes.php_fpm_run = {};
            };

        services = {
            nginx.service = defaults.service // {
                build.context = "${dockerfiles.nginx}";
                volumes = [
                    "${nginxConfig.user}:/etc/nginx/nginx.conf:ro"
                    "${volumes.websites.volume}:/var/www:ro"
                ] ++ (lib.optional exists."ssl.certificate"
                    "${secrets.ssl.certificate}:/etc/nginx/certs/certificate.pem:ro"
                ) ++ (lib.optional exists."ssl.key"
                    "${secrets.ssl.key}:/etc/nginx/certs/key.pem:ro"
                ) ++ (lib.optional features.php.enabled
                    "php_fpm_run:/var/run/php-fpm"
                );
                ports = let
                    bind = config.nzc.project.network.bindPortTo;
                in [
                    (bind "http" "tcp" 80)
                    (bind "https" "tcp" 443)
                ];
                restart = "unless-stopped";
            } // lib.optionalAttrs features.php.enabled {
                depends_on = [ "php" ];
            };
        } // (lib.optionalAttrs features.php.enabled {
            php.service = defaults.service // {
                build.context = "${dockerfiles.php-fpm}";              
                volumes = [
                    "php_fpm_run:/var/run/php-fpm"
                    "${phpConfig.ini.user}:/usr/local/etc/php/conf.d/php.ini:ro"
                    "${phpConfig.www.user}:/usr/local/etc/php-fpm.d/www.conf:ro"
                    "${volumes.websites.volume}:/var/www:ro"

                ];
                restart = "always";
            };
        });
    };
}
