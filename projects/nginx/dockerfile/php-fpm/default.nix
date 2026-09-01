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
    IMAGE_TAG ? "fpm-alpine3.17",
    phpSettings,
    lib,
    writeText,
    runCommand
}:
let
    packages = lib.concatStringsSep " " phpSettings.packages;
    extensions = lib.concatStringsSep " " phpSettings.extensions;
    Dockerfile = (writeText "Dockerfile" ''
    FROM php:${IMAGE_TAG}
    RUN apk add --no-cache ${packages}
    RUN docker-php-ext-install ${extensions}
    RUN mkdir /mnt/admin 
    ${if phpSettings.debug then ''
    RUN cp /usr/local/etc/php/php.ini-development $PHP_INI_DIR/conf.d/php.ini &&\
        echo "error_log = /proc/1/fd/2" >> $PHP_INI_DIR/conf.d/php.ini &&\
        echo "access_log = /proc/1/fd/2" >> $PHP_INI_DIR/conf.d/php.ini &&\
        echo "fastcgi.logging = On" >> $PHP_INI_DIR/conf.d/php.ini &&\
        echo "display_errors = stderr" >> $PHP_INI_DIR/conf.d/php.ini
    '' else ''
    RUN cp $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/conf.d/php.ini &&\
        echo "error_log = /proc/1/fd/2" >> $PHP_INI_DIR/conf.d/php.ini &&\
        echo "access_log = /proc/1/fd/2" >> $PHP_INI_DIR/conf.d/php.ini &&\
        echo "fastcgi.logging = On" >> $PHP_INI_DIR/conf.d/php.ini
    ''}
    '');
in
runCommand "docker-context" {} ''
    mkdir -p $out
    cp ${Dockerfile} $out/Dockerfile
''
