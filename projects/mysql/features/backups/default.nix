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

{ pkgs, lib, config, ... }:

let
    defaults = config.nzc.arion.defaults;
    instance = config.nzc.instance;
    secrets = instance.secrets;
    features = instance.features;
    dockerTags = instance.docker.tags;

    uid = instance.user.uid;
    gid = instance.user.gid;

    exists = {
        "dockerTags.backups" = dockerTags ? "backups";
    };

    dockerfile = pkgs.callPackage ./dockerfile ({
        PUID = toString uid;
        PGID = toString gid;
    } // lib.optionalAttrs (exists."dockerTags.backups") {
        IMAGE_TAG = dockerTags.backups;
    });
in
{
    options = with lib; {
        nzc.instance = {
            backup = {
                maxBackups = mkOption {
                    description = ''Maximum number of backups to keep.'';
                    type = types.int;
                };

                intervalDays = mkOption {
                    description = ''Backup interval in days.'';
                    type = types.int;
                };

                compressionLevel = mkOption {
                    description = ''The gzip compression level for backup creation.'';
                    type = types.enum [ 1 2 3 4 5 6 7 8 9 ];
                    default = 9;
                };
            };
        };
    };

    config = with lib; mkIf features.backups.enabled {
        docker-compose = defaults.docker-compose // {
            volumes = {
                "mysql_backups" = {};
                "mysql_backups_spool" = {};
            };
        };

        services = {
            backups-permissions.service = config.nzc.arion.presets.service.permissions // {
                volumes = [
                    "mysql_backups:/mnt/backups"
                    "mysql_backups_spool:/mnt/anacron-spool"
                ];
            };

            backups.service = defaults.service // {
                build.context = "${dockerfile}";
                volumes = [
                    "mysql_backups:/backup"
                    "mysql_backups_spool:/home/mysql-backup/.anacron/spool"
                    "${secrets."admin.password"}:/run/secrets/admin-password:ro"
                ];
                environment = {
                    MYSQLDUMP_OPTS = "--no-tablespaces";
                    MYSQL_HOST = "mysql";
                    MYSQL_PORT = 3306;
                    MYSQL_USER = instance.mysql.adminName;
                    MYSQL_PASS_FILE = "/run/secrets/admin-password";
                    ANACRON_DAYS = instance.backup.intervalDays;
                    MAX_BACKUPS = instance.backup.maxBackups;
                    GZIP_LEVEL = instance.backup.compressionLevel;
                };
                networks = [ "mysql" ];
                depends_on = {
                    backups-permissions.condition = "service_completed_successfully";
                    mysql.condition = "service_healthy";
                };
                restart = mkDefault "unless-stopped";
            };
        };
    };
}
