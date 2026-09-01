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

{ pkgs, ... }:

{
    project = "nginx";
    instance = {
        user = {
            uid = 1200;
            gid = 1200;
        };

        network.ports = {
            http.number = 80;
            https.number = 443;
        };

        features.php.enabled = true;
        php.debug = true;

        storage.volumes = {
            websites = {
                volume = "${pkgs.writeTextDir "index.html" ''
                    <html>
                        <body>
                            <h1><q>Hello World</q> - nzc-nix-docker</h1>
                        </body>
                    </html>
                ''}";
            };
        };

        nginxConfig = (pkgs.writeText "config" ''
            pid /tmp/nginx.pid;

            worker_processes auto;

            events {
                worker_connections 1024;
            }

            http {
                include       mime.types;
                default_type  application/octet-stream;
                sendfile      on;

                server {
                    listen 80;
                    server_name _;

                    root /var/www;
                    index index.html index.htm;

                    location / {
                        try_files $uri $uri/ =404;
                    }
                }

                # server {
                #     listen 443 ssl;
                #     server_name _;
                #
                #     ssl_certificate     /etc/nginx/certs/certificate.pem;
                #     ssl_certificate_key /etc/nginx/certs/key.pem;
                #
                #     root /var/www;
                #     index index.html index.htm;
                #
                #     location / {
                #         try_files $uri $uri/ =404;
                #     }
                # }
            }
        '');
    };
}
