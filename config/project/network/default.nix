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
    options.nzc.project.network = mkOption {
        description = ''Network settings for project'';
        type = types.submodule {
            options = {
                endpoints = mkOption {
                    description = ''The logical endpoints required by this project'';
                    type = types.listOf types.str;
                    default = [];
                    example = [
                        "website"
                        "game"
                    ];
                };
            };
        };
        default = {};
    };

    config.assertions = let
        project-endpoints = config.nzc.project.network.endpoints;
        instance-endpoints = map (e: e.id) config.nzc.instance.network.endpoints;
        missing-endpoints = builtins.filter (id: !(builtins.elem id project-endpoints)) instance-endpoints;
    in [
        {
            assertion = builtins.length instance-endpoints == builtins.length project-endpoints;
            message = ''
                Instance endpoints does not match project endpoints

                Project endpoints:
                ${toString project-endpoints}

                Instance endpoints:
                ${toString instance-endpoints}
            '';
        }
        {
            assertion = builtins.length missing-endpoints == 0;
            message = ''
            Instance is missing an endpoint.

            Endpoints needed by project:
            ${toString missing-endpoints}
            '';
        }
    ];
}
