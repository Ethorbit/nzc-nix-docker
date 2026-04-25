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
    writeText,
    UNAME,
    GNAME
}:

writeText "entrypoint.sh" ''
    #!/bin/sh
    set -e

    # Setup password
    echo "${UNAME}:$(cat /run/secrets/password)" | chpasswd
    passwd -u ${UNAME}

    # Setup auth key
    AUTH_KEYS="/home/${UNAME}/.ssh/authorized_keys"
    touch "$AUTH_KEYS"

    if [ -f /run/secrets/sftp-public-key ]; then
        echo "command=\"internal-sftp\",no-pty,no-port-forwarding $(cat /run/secrets/sftp-public-key)" >> "$AUTH_KEYS"
    fi

    if [ -f /run/secrets/ssh-public-key ]; then
        cat /run/secrets/ssh-public-key >> "$AUTH_KEYS"
    fi

    chmod 600 "$AUTH_KEYS"
    chown "${UNAME}:${GNAME}" "$AUTH_KEYS"

    # Run
    exec "$@"
''
