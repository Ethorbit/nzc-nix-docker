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

let
    project-endpoints  = config.nzc.project.network.endpoints;
    instance-endpoints = map (e: e.id) config.nzc.instance.network.endpoints;
    missing-endpoints  = builtins.filter (id: !(builtins.elem id instance-endpoints)) project-endpoints;
in
{
    options.nzc.project.network.endpoints = mkOption {
        description = ''The logical endpoints required by this project'';
        type = types.listOf types.str;
        default = [];
        example = [ "website" "game" ];
    };

    config.warnings = lib.filter (x: x != null && x != "") [
        (
            if builtins.length missing-endpoints > 0 
            || builtins.length project-endpoints != builtins.length instance-endpoints 
            then ''
                WARNING: This project expects certain network endpoints to be available in this instance.
                Missing endpoints: ${toString missing-endpoints}
                Project requires: ${toString project-endpoints}
                Instance provides: ${toString instance-endpoints}

                The project will still run, but some features may not work until these endpoints are configured.
            ''
            else
                null
        )
    ];
}
