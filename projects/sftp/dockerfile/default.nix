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

{
    callPackage,
    writeText,
    runCommand,
    UNAME ? "ssh",
    GNAME ? "ssh",
    PUID ? "1000",
    PGID ? "1000",
    ALLOW_PASSWORD_LOGIN,
    PASSWORD,
    SFTP_PUBLIC_KEY,
    SSH_PUBLIC_KEY
}:
let
    authorized_keys = callPackage ./authorized_keys.nix {
        inherit SFTP_PUBLIC_KEY SSH_PUBLIC_KEY;
    };

    sshd_config = callPackage ./sshd_config.nix {
        inherit UNAME ALLOW_PASSWORD_LOGIN;
    };

    Dockerfile = (writeText "Dockerfile" ''
    FROM alpine:3.23.3
    COPY sshd_config /etc/ssh/sshd_config
    RUN apk add --no-cache openssh rsync shadow &&\
        groupadd -g ${PGID} ${UNAME} &&\
        useradd -m -u ${PUID} -g ${PGID} ${UNAME} &&\
        echo "${UNAME}:${PASSWORD}" | chpasswd &&\
        passwd -u ${UNAME} &&\
        mkdir -p /home/${UNAME}/.ssh &&\
        chown ${UNAME}:${GNAME} -R /home/${UNAME}/ &&\
        chmod 700 /home/${UNAME}/.ssh/ &&\
        ssh-keygen -A
    USER ${UNAME}
    COPY --chown=${UNAME}:${GNAME} \
        authorized_keys /home/${UNAME}/.ssh/authorized_keys
    RUN chmod 600 /home/${UNAME}/.ssh/authorized_keys
    USER root
    CMD ["/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config"]
    '');
in
runCommand "docker-context" {} ''
    mkdir -p $out
    cp ${authorized_keys} $out/authorized_keys
    cp ${sshd_config} $out/sshd_config
    cp ${Dockerfile} $out/Dockerfile
    cat $out/Dockerfile
''
