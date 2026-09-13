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
    IMAGE_TAG ? "0ac2cf1",
    PUID ? "1000",
    PGID ? "1000",
    writeText,
    runCommand
}:
let
    Dockerfile = (writeText "Dockerfile" ''
    FROM ethorbit/discord-server-status:${IMAGE_TAG}
    USER root
    ARG UID
    ARG GID
    RUN apk update &&\
        apk add --no-cache shadow &&\
        usermod -u "${PUID}" server-status &&\
        groupmod -g "${PGID}" server-status
    USER server-status
    '');
in
runCommand "docker-context" {} ''
    mkdir -p $out
    
    cp ${Dockerfile} $out/Dockerfile
    cat $out/Dockerfile
''
