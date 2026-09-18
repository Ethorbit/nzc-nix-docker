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
    volumes = instance.storage.volumes;

    uid = instance.user.uid;
    gid = instance.user.gid;

    exists = {
        "phpmyadmin.config" = volumes ? "phpmyadmin.config";
        "dockerTags.phpmyadmin" = dockerTags ? "phpmyadmin";
        "ssl.certificate" = secrets ? "ssl.certificate";
        "ssl.key"  = secrets ? "ssl.key";
    };

    containerSecretPaths = {
        mysqlPassword = "/run/secrets/mysql-password";
        blowfishSecret = "/run/secrets/phpmyadmin-blowfishsecret";
        sslCertificate = "/run/secrets/ssl-certificate";
        sslKey = "/run/secrets/ssl-key";
    };

    defaultConfig = with containerSecretPaths; 
        (pkgs.callPackage ./app-config/phpmyadmin/config.inc.php.nix ({
            inherit mysqlPassword blowfishSecret;
            host = "mysql";
            user = "root";
        } // lib.optionalAttrs (exists."ssl.certificate" && exists."ssl.key") {
            inherit sslCertificate sslKey;
        }));

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

    config = lib.mkIf features.phpmyadmin.enabled {
        warnings = lib.optional 
                (!exists."phpmyadmin.config")
                ''storage.volumes."phpmyadmin.config".volume wasn't set, using a default config.inc.php file.'';

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

            storage.volumes = [
                {
                    id = "phpmyadmin.config";
                    required = false;
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
                "phpmyadmin-temp" = {};
                "phpmyadmin-web" = {};
            };
        };

        services = with lib; {
            phpmyadmin-permissions.service = config.nzc.arion.presets.service.permissions // {
                volumes = [
                    "phpmyadmin:/mnt/panel"
                    "phpmyadmin-temp:/mnt/panel-tmp"
                ];
            };

            phpmyadmin.service = defaults.service // {
                build.context = "${dockerfile}";
                volumes = [
                    "phpmyadmin:/panel"
                    "phpmyadmin-temp:/panel/tmp"
                ] ++ lib.optional (exists."phpmyadmin.config")
                    "${volumes."phpmyadmin.config".volume}:/var/www/html/config.inc.php:ro"
                ++ lib.optional (!exists."phpmyadmin.config")
                    "${defaultConfig}:/var/www/html/config.inc.php:ro";
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
                volumes = with containerSecretPaths; 
                    nginxProject.config.services.php.service.volumes ++ [
                        "phpmyadmin:/srv/phpmyadmin:ro"
                        "phpmyadmin-temp:/srv/phpmyadmin/tmp"
                        "${secrets."admin.password"}:${mysqlPassword}:ro"
                        "${secrets."phpmyadmin.blowfish"}:${blowfishSecret}:ro"
                        "${secrets."ssl.certificate"}:${sslCertificate}:ro"
                        "${secrets."ssl.key"}:${sslKey}:ro"
                    ];
                depends_on = {
                    phpmyadmin.condition = "service_started";
                };
                networks = [ "mysql" ];
            };
        };
    };
}
