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
    secrets = instance.secrets;
    features = instance.features;
    dockerTags = instance.docker.tags;

    uid = instance.user.uid;
    gid = instance.user.gid;

    exists = {
        "dockerTags.bot" = dockerTags ? "bot";
        "token"  = secrets ? "token";
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

    options = with lib; {
        nzc.instance.bot = {
            stickyCooldown = mkOption {
                type = types.int;
                default = 20000;

                description = ''
                Minimum time, in milliseconds, that must pass since a 
                sticky message was last shown in a channel before it 
                can be shown again. 

                Corresponds to the STICKY_COOLDOWN environment variable.'';
            };
        };
    };

    config = {
        nzc.project = {
            secrets = [
                {
                    id = "bot.token";
                    required = true;
                }
            ];

            storage.volumes = [
                {
                    id = "bot";
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
            stickymessages-permissions.service = config.nzc.arion.presets.service.permissions // {
                volumes = [
                    "${volumes."bot".volume}:/mnt/botdb"
                ];
            };

            stickymessages.service = defaults.service // {
                build.context = "${dockerfile}";
                volumes = [
                    "${volumes."bot".volume}:/botdb"
                    "${secrets."bot.token"}:/run/secrets/bot-token:ro"
                ];
                environment = {
                    STICKY_COOLDOWN = instance.bot.stickyCooldown;
                    BOT_TOKEN_FILE = "/run/secrets/bot-token";
                };
                depends_on = {
                    stickymessages-permissions.condition = "service_completed_successfully";
                };
                restart = "unless-stopped";
            };
        };
    };
}
