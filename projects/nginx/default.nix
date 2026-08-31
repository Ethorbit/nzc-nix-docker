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
    nginxConfig = instance.nginxConfig;

    exists = {
        nginxConfig = nginxConfig != null;
        "ssl.certificate" = secrets ? "ssl.certificate";
        "ssl.key"  = secrets ? "ssl.key";
    };

    dockerfile = pkgs.callPackage ./dockerfile {
        PUID = toString instance.user.uid;
        PGID = toString instance.user.gid;
    } // lib.optionalAttrs exists."ssl.certificate" {
        SSL_CERT = secrets."ssl.certificate";
        SSL_KEY = secrets."ssl.key";
    };
in
{
    imports = [
        ../../config
    ];

    options = with lib; {
        nzc.instance.nginxConfig = mkOption {
            type = types.nullOr types.path;
            default = null;
        };
    };

    config = {
        nzc.project = {
            # TODO: make features require user to set enabled false / true in (../config/project)
            # before using it to toggle PHP functionality.
            #features = [
            #    "php"
            #];

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
                    id = "configuration";
                    required = false;
                }
                {
                    id = "websites";
                    required = true;
                }
            ];
        };

        assertions = [
            {
                assertion = exists.nginxConfig;
                message = "You must specify nginxConfig: a file path to your nginx configuration.";
            }
            {
                assertion = exists."ssl.certificate" == exists."ssl.key";
                message = "ssl.certificate and ssl.key must either both be defined or both be undefined.";
            }
        ];

        project = defaults.project;
        docker-compose = defaults.docker-compose;
        services = {
            nginx.service = defaults.service // {
                build.context = "${dockerfile}";
                volumes = [
                    "${volumes.websites.volume}:/var/www:ro"
                ] ++ (lib.optional exists.nginxConfig
                    "${nginxConfig}:/etc/nginx/nginx.conf:ro"
                ) ++ (lib.optional exists."ssl.certificate"
                    "${secrets.ssl.certificate}:/etc/nginx/certs/certificate.pem:ro"
                ) ++ (lib.optional exists."ssl.key"
                    "${secrets.ssl.key}:/etc/nginx/certs/key.pem:ro"
                );
                ports = let
                    bind = config.nzc.project.network.bindPortTo;
                in [
                    (bind "http" "tcp" 80)
                    (bind "https" "tcp" 443)
                ];
                restart = "unless-stopped";
            };
        };
    };
}
