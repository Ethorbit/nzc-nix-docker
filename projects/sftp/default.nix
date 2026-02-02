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

{ config, pkgs, ... }:
let
    defaults = config.nzc.arion.defaults;
    instance = config.nzc.instance;
    secrets = instance.secrets;

    exists = {
      "sftp.public.key" = secrets ? "sftp.public.key";
      "ssh.public.key"  = secrets ? "ssh.public.key";
    };

    dockerfile = pkgs.callPackage ./dockerfile {
        PUID = toString instance.user.uid;
        PGID = toString instance.user.gid;
        PASSWORD = secrets."password";
        ALLOW_PASSWORD_LOGIN = (!exists."sftp.public.key" && !exists."ssh.public.key");
        SFTP_PUBLIC_KEY = if exists."sftp.public.key" then secrets."sftp.public.key" else "";
        SSH_PUBLIC_KEY = if exists."ssh.public.key" then secrets."ssh.public.key" else "";
    };
in
{
    imports = [
        ../../config
    ];

    config = {
        nzc.project = {
            network.ports = [
                {
                    id = "sftp";
                    required = true;
                }
            ];

            secrets = [
                {
                    id = "password";
                    required = true;
                }
                {
                    id = "sftp.public.key";
                }
                {
                    id = "ssh.public.key";
                }
            ];
        };

        assertions = if (exists."sftp.public.key" && exists."ssh.public.key") then [
            {
                assertion = secrets."sftp.public.key" != secrets."ssh.public.key";
                message = ''
                    The SSH public key for SFTP and SSH MUST be different:
                    You cannot connect to both at the same time!
                '';
            }
        ] else [];

        project = defaults.project;
        services.sftp.service = defaults.service // {
            build.context = "${dockerfile}";
            ports = [
                "${toString instance.network.ports.sftp}:22/tcp"
            ];
        };
    };
}
