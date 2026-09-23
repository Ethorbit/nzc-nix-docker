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
    dockerfile = pkgs.callPackage ./dockerfile ({
        PUID = toString instance.user.uid;
        PGID = toString instance.user.gid;
    });
    exists = {
        "script" = volumes ? "script";
    };
in
{
    imports = [
        ../../../config
    ];

    options.nzc.instance = with lib; {
        mkcert = {
            domainName = mkOption {
                type = types.str;
                example = "mysite.com";
            };

            checkInterval = mkOption {
                description = "Seconds between certificate re-checks and hook runs.";
                type = types.int;
                default = 3600;
            };
        };
    };

    config = {
        nzc.project = {
            storage.volumes = [
                {
                    id = "script";
                    required = false;
                }
                {
                    id = "certificates";
                    required = false;
                }
            ];
        };

        project = defaults.project;
        docker-compose = defaults.docker-compose;
        services.mkcert.service = defaults.service // {
            build.context = "${dockerfile}";
            volumes = [
                "${volumes.certificates.volume}:/mnt"
            ] ++ lib.optional (exists."script")
                "${volumes.script.volume}:/script";
            environment = {
                HOOK = "/script";
                CHECK_INTERVAL = instance.mkcert.checkInterval;
                DOMAIN_NAME="${instance.mkcert.domainName}";
                PUBLIC_KEY = "/mnt/mkcert.pem";
                PRIVATE_KEY = "/mnt/mkcert.key";
            };
            network_mode = "none";
            restart = "on-failure";
        };
    };
}
