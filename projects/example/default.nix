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

{ config, pkgs, lib, ... }:
let
    base = (import ../../lib/base/arion { inherit lib config; }) // {
        instance = import ./instance-type.nix { inherit lib; };
    };
    dockerfile = pkgs.callPackage ./dockerfile {};
in
{
    imports = [ base.instance ];
    config = {
        project = base.project;
        services.example.service = base.service // {
            build.context = "${dockerfile}";
        };
    };
}
