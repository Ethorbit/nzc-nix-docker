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

{ config, lib, pkgs, ... }:
let
    defaults = config.nzc.arion.defaults;
    instance = config.nzc.instance;
    volumes = instance.storage.volumes;
    dockerTags = instance.docker.tags;

    uid = instance.user.uid;
    gid = instance.user.gid;

    exists = {
        "dockerTags.bot" = dockerTags ? "bot";
    };

    dockerfile = pkgs.callPackage ./dockerfile ({
        PUID = toString uid;
        PGID = toString gid;
    } // lib.optionalAttrs (exists."dockerTags.bot") {
        IMAGE_TAG = dockerTags."bot";
    });
in
{
    imports = [
        ../../../config
    ];

    config = {
        nzc.project = {
            storage.volumes = [
                {
                    id = "bot.config";
                    required = true;
                }
            ];

            docker.tags = [ "bot" ];
        };

        project = defaults.project;
        docker-compose = defaults.docker-compose // {
            volumes.discord_sticky_bot = {};
        };

        services = {
            server-status.service = defaults.service // {
                build.context = "${dockerfile}";
                volumes = [
                    "${volumes."bot.config".volume}:/server-status/config.json:ro"
                ];
                restart = "unless-stopped";
            };
        };
    };
}
