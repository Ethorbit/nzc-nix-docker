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

{ config, lib, ... }:

with lib;

{
    options.nzc.project.storage = mkOption {
        description = ''Storage settings for the project'';
        type = types.submodule {
            options = {
                volumes = mkOption {
                    description = ''Volumes the project will use'';
                    type = types.listOf (types.submodule {
                        options = {
                            id = mkOption {
                                description = ''Identifier for this volume'';
                                type = types.str;
                            };

                            required = mkOption {
                                description = ''
                                Whether or not the project requires the user to do something with this volume
                                '';
                                type = types.bool;
                                default = false;
                            };
                        };
                    });
                    default = [];
                    example = [
                        {
                            id = "gmod";
                            required = false;
                        }
                    ];
                };
            };
        };
        default = {};
    };

    config.nzc.project.checks = [
        {
            name = "storage.volumes";
            official = config.nzc.project.storage.volumes;
            user = config.nzc.instance.storage.volumes;
        }
    ];
}
