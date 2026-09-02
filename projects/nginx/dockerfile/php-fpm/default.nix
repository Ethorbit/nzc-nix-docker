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
    PUID,
    PGID,
    phpSettings,
    lib,
    callPackage,
    writeText,
    runCommand
}:
let
    startScript = callPackage ./start.nix { inherit PUID PGID; };

    packages = lib.concatStringsSep " " phpSettings.packages;
    extensions = lib.concatStringsSep " " phpSettings.extensions;
    Dockerfile = (writeText "Dockerfile" ''
    FROM php:${IMAGE_TAG}
    WORKDIR /
    RUN apk add --no-cache ${packages}
    RUN docker-php-ext-install ${extensions}
    RUN mkdir /mnt/admin &&\
        addgroup -g ${PGID} php && adduser -D -u ${PUID} -G php php
    COPY start.sh /start.sh
    RUN chmod +x /start.sh
    CMD [ "/start.sh" ]
    '');
in
runCommand "docker-context" {} ''
    mkdir -p $out
    cp ${startScript} $out/start.sh
    cp ${Dockerfile} $out/Dockerfile
''
