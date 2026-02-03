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

{ config, pkgs, ... }:

let
    nzc = config.nzc;
    defaults = nzc.arion.defaults;
    instance = nzc.instance;

    exists = {
        "token.steam" = instance.secrets ? "token.steam";
        "password.rcon" = instance.secrets ? "password.rcon";
    };

    dockerfiles = with pkgs; {
        gmod = callPackage ./dockerfile {
            PUID = toString instance.user.uid;
            PGID = toString instance.user.gid;
            RCON_PASSWORD = if exists."password.rcon" 
                            then instance.secrets."password.rcon"
                            else "";
            STEAM_LOGIN_TOKEN = if exists."token.steam"
                            then instance.secrets."token.steam"
                            else "";
        };
    };
in
{
    imports = [
        ../../../config
    ];

    nzc.project = {
        storage.volumes = [
            {
                id = "gmod";
                required = true;
            }
            {
                id = "shared";
                required = true;
            }
        ];

        network.ports = [
            {
                id = "gmod";
                required = true;
            }
        ];

        secrets = [
            {
                id = "token.steam";
                required = false;
            }
            {
                id = "password.rcon";
                required = false;
            }
        ];
    };

    project = defaults.project;
    docker-compose = defaults.docker-compose;

    services = {
        gmod-permissions.service = nzc.arion.presets.service.permissions // {
            volumes = [
                "${instance.storage.volumes.gmod}:/mnt/gmod"
                "${instance.storage.volumes.shared}:/mnt/shared"
            ];
        };

        gmod.service = defaults.service // {
            build.context = "${dockerfiles.gmod}";
            volumes = [
                "${instance.storage.volumes.gmod}:/home/steam/Steam/steamapps/common"
                "${instance.storage.volumes.shared}:/shared"
            ];
            ports = [
                "${toString instance.network.ports.gmod}:27015/tcp"
                "${toString instance.network.ports.gmod}:27015/udp"
            ];
            restart = "unless-stopped";
        };
    };
}
