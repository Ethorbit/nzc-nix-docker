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

let
    count = 6;
    initialPort = 27019;
    ftpPort = 40000;
    user = {
        uid = 2000;
        gid = 2000;
    };

    gmods = (
        builtins.listToAttrs (
            builtins.genList (i: let
                serverNumber = i + 1;
                portNumber = initialPort + i;
                name = "gmod_${toString serverNumber}";
            in {
                inherit name;
                value = {
                    project = "gameserver/gmod";
                    instance = {
                        inherit user;
                        storage.volumes = {
                            gmod.volume = name;
                            shared = {
                                volume = "gmod_shared";
                                scope = "global";
                            };
                        };
                        network.ports.gmod = portNumber;
                        secrets = {
                            "password.rcon" = builtins.toFile "helloworld" "testme";
                        };
                    };
                };
            }) count
        )
    );
in
    # Gmod cluster
    gmods 
    // # Remotely manage its files
    {
        gmod_sftp = {
            project = "sftp";
            instance = {
                inherit user;
                network.ports.sftp = ftpPort;
                storage.volumes = builtins.listToAttrs (
                    builtins.concatLists (
                        builtins.map (v:
                            builtins.map (vol: {
                                name = vol.volume;
                                value = {
                                    volume = vol.volume;
                                    scope = "global";
                                };
                            }) (builtins.attrValues v.instance.storage.volumes)
                        ) (builtins.attrValues gmods)
                    )
                );
                secrets."password" = builtins.toFile "helloworld" "123secure";
            };
        };
    }
