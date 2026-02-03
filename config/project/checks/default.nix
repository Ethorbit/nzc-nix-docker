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
    checks = config.nzc.project.checks;

    extractIds = val:
        if builtins.isList val then
            map (o:
                if builtins.isString o then o
                else o.id
            ) val
        else builtins.attrNames val;

    normalizeOfficial = official:
        let
            ids = extractIds official;
        in
        if builtins.isList official then
            if builtins.length official > 0 && !builtins.isString (builtins.head official) then
                {
                    required = map (o: o.id)
                        (builtins.filter (o: o.required or false) official);
                    optional = map (o: o.id)
                        (builtins.filter (o: !(o.required or false)) official);
                }
            else
                {
                    required = ids;
                    optional = [];
                }
        else
            {
                required = ids;
                optional = [];
            };

    mkResult = check:
        let
            official = normalizeOfficial check.official;
            user = extractIds check.user;
            missing-required =
                builtins.filter (id: !(builtins.elem id user)) official.required;
            missing-optional =
                builtins.filter (id: !(builtins.elem id user)) official.optional;
        in
        {
            assertions =
                [
                    {
                        assertion = builtins.length missing-required == 0;
                        message = ''
                            ERROR: Required items are missing in '${check.name}'.
                            Missing required: ${toString missing-required}
                            User provides:    ${toString user}
                        '';
                    }
                ];
            warnings =
                if builtins.length missing-optional > 0
                then [
                    ''
                        WARNING: Optional items are missing in '${check.name}'.
                        Missing optional: ${toString missing-optional}
                        User provides:    ${toString user}
                    ''
                ]
                else [];
        };

    results = map mkResult checks;
in
{
    options.nzc.project.checks = mkOption {
        description = ''Generic project vs user consistency checks'';
        type = types.listOf (types.submodule {
            options = {
                name = mkOption {
                    type = types.str;
                };

                official = mkOption {
                    type = types.anything;
                };

                user = mkOption {
                    type = types.anything;
                };
            };
        });
        default = [];
    };

    config = {
        assertions = builtins.concatLists (map (r: r.assertions) results);
        warnings   = builtins.concatLists (map (r: r.warnings) results);
    };
}
