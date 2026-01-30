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

{ lib, ... }:

with lib;

{
    imports = [
        ./network
        ./storage
        ./limit
    ];

    options.nzc.instance = mkOption {
        description = ''nZC Container instance'';
        type = types.submodule {
            options = {
                name = mkOption {
                    type = types.str;
                    description = "Unique instance name";
                    example = "my-cool-container";
                };

                user = mkOption {
                    type = types.submodule {
                        options = {
                            uid = mkOption {
                                description = "User ID the main process will run under.";
                                type = types.int;
                                default = 0;
                                example = 1000;
                            };

                            gid = mkOption {
                                description = "Group ID the main process will run under.";
                                type = types.int;
                                default = 0;
                                example = 1000;
                            };
                        };
                    };
                };

                labels = mkOption {
                    description = ''Labels assigned to the container'';
                    type = types.attrsOf types.str;
                    default = {};
                    example = {
                        "label" = "value";
                    };
                };
            };
        };
        example = import ./example.nix;
    };
}
