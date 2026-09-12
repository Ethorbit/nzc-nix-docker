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
            PMA_HOST = "mysql";
            MYSQL_USER = "root";
        };
        user = instance.phpmyadmin.config;
        default = pkgs.callPackage ./config.inc.php.nix defaultSettings;
    };

    exists = {
        "dockerTags.phpmyadmin" = dockerTags ? "phpmyadmin";
        "ssl.certificate" = secrets ? "ssl.certificate";
        "ssl.key"  = secrets ? "ssl.key";
    };

    dockerfile = (pkgs.callPackage ./dockerfile ({
        PUID = toString uid;
        PGID = toString gid;
    } // (lib.optionalAttrs exists."dockerTags.phpmyadmin" {
        IMAGE_TAG = dockerTags."phpmyadmin";
    })));

    stripUndefined = attrs: keys: builtins.removeAttrs attrs keys;

    arionEval = config.nzc.arion.eval;
    nginxProject = arionEval {
        modules = [
            ../../../nginx
            ../../../../config
            ({ config, ... }: {
                nzc.instance = {
                    user = { inherit uid gid; };
                    network.ports = {
                        http.number = instance.network.ports."http".number;
                        https.number = instance.network.ports."https".number;
                    };

                    secrets = lib.optionalAttrs (exists."ssl.certificate") {
                        "ssl.certificate" = secrets."ssl.certificate";
                    } // lib.optionalAttrs (exists."ssl.key") {
                        "ssl.key" = secrets."ssl.key";
                    };

                    features.php.enabled = true;
                    storage.volumes.websites.volume = "phpmyadmin-web";
                    nginx.config = {
                        serverDirectory = lib.mkDefault (pkgs.callPackage ./app-config/nginx/conf.d.default.nix {
                            key = secrets."ssl.key" or null;
                            certificate = secrets."ssl.certificate" or null;
                        });
                    };
                };
            })
        ];
        inherit pkgs;
    };
in
{
    imports = [
        ../../../nginx/options.nix
    ];

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
        warnings = lib.optional 
                (phpmyadminConfig.user == phpmyadminConfig.default)
                ''phpmyadmin.config wasn't set, using a default config.inc.php file.'';

        assertions = nginxProject.config.assertions ++ [
            {
                assertion = exists."ssl.certificate" == exists."ssl.key";
                message = "ssl.certificate and ssl.key must either both be defined or both be undefined.";
            }
        ];

        nzc.project = {
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
                    id = "phpmyadmin.blowfish";
                    required = true;
                }
            ];
        
            docker.tags = [ "phpmyadmin" ];
        };

        docker-compose = {
            volumes = nginxProject.config.docker-compose.volumes // {
                "phpmyadmin" = {};
                "phpmyadmin-web" = {};
            };
        };

        services = with lib; {
            phpmyadmin-permissions.service = config.nzc.arion.presets.service.permissions // {
                volumes = [
                    "phpmyadmin:/mnt/panel"
                ];
            };

            phpmyadmin.service = defaults.service // {
                build.context = "${dockerfile}";
                volumes = [
                    "${phpmyadminConfig.user}:/var/www/html/config.inc.php:ro"
                    "phpmyadmin:/panel"
                ];
                depends_on.phpmyadmin-permissions.condition = "service_completed_successfully";
                network_mode = "none";
                restart = mkDefault "on-failure";
            };

            nginx.service = (stripUndefined nginxProject.config.services.nginx.service ["healthcheck" "assertWarn"]) // {
                volumes = nginxProject.config.services.nginx.service.volumes ++ [
                    "phpmyadmin:/srv/phpmyadmin:ro"
                ];
                depends_on = {
                    phpmyadmin = {};
                    
                    mysql.condition = "service_healthy";
                };
            };

            php.service = (stripUndefined nginxProject.config.services.php.service ["healthcheck" "assertWarn"]) // {
                volumes = nginxProject.config.services.php.service.volumes ++ [
                    "phpmyadmin:/srv/phpmyadmin:ro"
                    "${secrets."admin.password"}:/run/secrets/mysql-password:ro"
                    "${secrets."phpmyadmin.blowfish"}:/run/secrets/phpmyadmin-blowfishsecret:ro"
                ];
                networks = [ "mysql" ];
            };
        };
    };
}
