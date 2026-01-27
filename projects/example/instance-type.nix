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

{ lib }:
with lib;
let
    base = import ../../lib/instance/type/base.nix { inherit lib; };
in
{
    imports = [ base ];

    options.instance = {
        # You can make project-specific options here
        project = mkOption {
            description = "Example project instance setting";
            type = types.submodule {
                options = {
                    name = mkOption {
                        description = "New setting for changing project name";
                        type = types.str;
                        default = "example";
                    };
                };
            };
            default = {};
        };
    };
}
