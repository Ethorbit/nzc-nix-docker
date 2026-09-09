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
    IMAGE_TAG ? "5.2.1-fpm-alpine",
    PUID ? "1000",
    PGID ? "1000",
    callPackage,
    writeText,
    runCommand
}:
let
    entrypoint = ./entrypoint.sh;
    start = ./start.sh;
    Dockerfile = (writeText "Dockerfile" ''
    FROM phpmyadmin:${IMAGE_TAG}
    VOLUME /panel
    COPY --chown=www-data:www-data ./*.sh /
    USER root
    WORKDIR /var/www/html
    RUN apk add --no-cache shadow &&\
        groupmod -g ${PGID} www-data &&\
        usermod -u ${PUID} www-data &&\
        mkdir -p /panel &&\
        chown -R www-data:www-data ./ &&\
        chmod 770 -R ./ &&\
        chown www-data:www-data /panel &&\
        chmod 770 /panel &&\
        chmod 755 /*.sh &&\
        chown www-data:www-data /*.sh &&\
        echo "Fixing stupid hardcoded config location" &&\
        sed -ri "s/^\s.*'configFile'.*/    'configFile'  => ROOT_PATH . 'config.inc.php',/" ./libraries/vendor_config.php
    USER www-data
    ENTRYPOINT [ "/entrypoint.sh" ]
    CMD [ "/start.sh" ]   
    '');
in
runCommand "docker-context" {} ''
    mkdir -p $out
    cp ${start} $out/start.sh
    cp ${entrypoint} $out/entrypoint.sh
    cp ${Dockerfile} $out/Dockerfile
    cat $out/Dockerfile
''
