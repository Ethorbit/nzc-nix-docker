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
    IMAGE_TAG ? "latest",
    PUID ? "1000",
    PGID ? "1000",
    writeText,
    runCommand
}:
let
    entrypoint = ./entrypoint.sh;

    Dockerfile = (writeText "Dockerfile" ''
    FROM ethorbit/discord_sticky-message-bot:${IMAGE_TAG}
    USER root
    ARG PUID
    ARG PGID
    ENV BOT_TOKEN_FILE=""
    COPY entrypoint.sh /entrypoint.sh
    RUN usermod -u "${PUID}" stickybot &&\
        groupmod -g "${PGID}" stickybot &&\
        chmod +x /entrypoint.sh
    USER stickybot
    ENTRYPOINT ["/entrypoint.sh"]
    CMD ["node", "./project/bot/src/bot.js"]
    '');
in
runCommand "docker-context" {} ''
    mkdir -p $out
    
    cp ${entrypoint} $out/entrypoint.sh
    cp ${Dockerfile} $out/Dockerfile
    cat $out/Dockerfile
''
