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

{ writeText }:

writeText "server-start.sh" ''
#!/bin/bash

# Uncomment for nZombies
#START_ARGS="-tickrate 33 -disableluarefresh +maxplayers 15 +gamemode nzombies +map nz_kino_der_toten"

# Only add +rcon_password if RCON_PASSWORD is set and not empty
if [ -n "$RCON_PASSWORD" ]; then
    RCON_ARG="+rcon_password $RCON_PASSWORD"
fi

# Only add +sv_setsteamaccount if STEAM_LOGIN_TOKEN is set and not empty
if [ -n "$STEAM_LOGIN_TOKEN" ]; then
    STEAM_ARG="+sv_setsteamaccount $STEAM_LOGIN_TOKEN"
fi

# Add -autoupdate if you care, but just know that it will take forever fetching updates on each startup, causing server startup to be delayed for no reason..
"''${SERVER_DIR}/srcds_run" \
    -port "''${PORT}" \
    -steam_dir "''${STEAMCMD_DIR}" \
    -steamcmd_script "''${SERVERS_DIR}/''${STEAMCMD_UPDATE_SCRIPT}" "''${START_ARGS}" \
    $STEAM_ARG \
    $RCON_ARG
''
