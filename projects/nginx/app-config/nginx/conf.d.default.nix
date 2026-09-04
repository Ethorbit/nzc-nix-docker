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

{ key, certificate, lib, writeTextDir }:
let
    setupSSL = (key != null && certificate != null);
in
writeTextDir "default.conf" ''
    server {
        listen 80;
        server_name _;

        root /var/www;
        index index.php index.html;

        location / {
            try_files $uri $uri/ /index.php?$query_string;
        }

        location ~ \.php$ {
            include fastcgi_params;
            fastcgi_pass unix:/var/run/php-fpm/sock;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        }
    }

    ${lib.optionalString setupSSL ''
    server {
        listen 443 ssl;
        server_name _;
        root /var/www;
        index index.php index.html;

        ssl_certificate     /etc/nginx/certs/certificate.pem;
        ssl_certificate_key /etc/nginx/certs/key.pem;
        ssl_protocols       TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers on;
        ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";
        ssl_ecdh_curve      secp384r1;
        ssl_session_cache   shared:SSL:10m;
        ssl_session_tickets off;
        ssl_stapling        on;
        ssl_stapling_verify on;

        location / {
            try_files $uri $uri/ /index.php?$query_string;
        }
        location ~ \.php$ {
            include fastcgi_params;
            fastcgi_pass unix:/var/run/php-fpm/sock;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        }
    }
    ''}
''
