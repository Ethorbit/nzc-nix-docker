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

{
    IMAGE_TAG ? "1.23-alpine-perl",
    PUID,
    PGID,
    SSL_CERT ? null,
    SSL_KEY ? null,
    callPackage,
    writeText,
    runCommand
}:

let
    entrypoint = {
        reloadOnFileChange =
            callPackage ./entrypoint/reload_on_file_change.nix {
                inherit SSL_CERT SSL_KEY;
            };
    };

    Dockerfile = (writeText "Dockerfile" ''
    FROM nginxinc/nginx-unprivileged:${IMAGE_TAG}
    USER root
    COPY ./*.sh /docker-entrypoint.d/
    RUN chmod +x /docker-entrypoint.d/*.sh &&\
        chown "${PUID}":"${PGID}" /docker-entrypoint.d/*.sh &&\
        apk add --no-cache shadow inotify-tools &&\
        rm /usr/share/nginx/html/*.html &&\
        usermod -u "${PUID}" nginx &&\
        groupmod -g "${PGID}" nginx &&\
        mkdir /mnt/admin &&\
        mkdir /mnt/admin/portainer
    USER nginx
    '');
in
runCommand "docker-context" {} ''
    mkdir -p $out
    cp ${entrypoint.reloadOnFileChange} $out/
    cp ${Dockerfile} $out/Dockerfile
''
