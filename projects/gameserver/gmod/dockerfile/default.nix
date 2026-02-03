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
    writeText,
    runCommand,
    callPackage,
    PUID ? "1000",
    PGID ? "1000",
    UMASK ? "007",
    STEAM_LOGIN_TOKEN ? "",
    RCON_PASSWORD ? ""
}:
let
    start = {
        container = callPackage ./start/container.nix {};
        server = callPackage ./start/server.nix {};
    };

    Dockerfile = (writeText "Dockerfile" ''
    FROM ethorbit/gmod-server:0733510
    ENV UMASK=${UMASK}
    ENV PORT=27015
    ENV STEAMCMD_UPDATE_SCRIPT_NOVALIDATE="steam_update_no_validate.txt"
    ENV STEAM_LOGIN_TOKEN=${STEAM_LOGIN_TOKEN}
    ENV RCON_PASSWORD=${RCON_PASSWORD}
    ENV START_ARGS="-tickrate 33 -disableluarefresh -port 27015 +maxplayers 15 +gamemode sandbox +map gm_flatgrass"
    COPY ./container-start.sh /start_two.sh
    COPY ./server-start.sh "''${IMAGE_DIR}/''${START_SCRIPT}"
    USER root
    RUN usermod -u "${PUID}" ''${USER} &&\
        groupmod -g "${PGID}" ''${USER} &&\
        chown ''${USER}:''${USER} /start_two.sh &&\
        chown ''${USER}:''${USER} "''${IMAGE_DIR}/''${START_SCRIPT}" &&\
        chmod 700 /start_two.sh &&\
        chmod 2770 "''${IMAGE_DIR}/''${START_SCRIPT}" &&\
        chown ''${USER}:''${USER} -R ''${HOME_DIR} &&\
        chown ''${USER}:''${USER} -R ''${IMAGE_DIR}
    USER ''${USER}
    CMD ["/start_two.sh"]
    '');
in
runCommand "docker-context" {} ''
    mkdir -p $out
    cp ${start.container} $out/container-start.sh
    cp ${start.server} $out/server-start.sh
    cp ${Dockerfile} $out/Dockerfile
    cat $out/Dockerfile
''
