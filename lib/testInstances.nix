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

{ lib, pkgs, projects }:

let
    findTests = prefix: dir:
        let
            entries = builtins.readDir dir;
            dirNames = builtins.attrNames (lib.filterAttrs (n: v: v == "directory") entries);
        in
        lib.concatMap (name:
            let
                subdir = "${dir}/${name}";
                fullName = if prefix == "" then name else "${prefix}-${name}";
                selfEntry = lib.optional (builtins.pathExists "${subdir}/test.nix") {
                    name = fullName;
                    value = import "${subdir}/test.nix" { inherit pkgs lib; };
                };
            in
            selfEntry ++ findTests fullName subdir
        ) dirNames;
in
    builtins.listToAttrs (findTests "" projects)
