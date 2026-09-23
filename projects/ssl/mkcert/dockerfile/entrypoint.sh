#!/bin/sh

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

[ ! -f "$PRIVATE_KEY" ] && [ ! -f "$PUBLIC_KEY" ] &&\
    mkcert -install &&\
    mkcert -cert-file /mnt/mkcert.pem -key-file /mnt/mkcert.key \
    ${DOMAIN_NAME} *.${DOMAIN_NAME}

chown mkcert:mkcert "$PUBLIC_KEY"
chown mkcert:mkcert "$PRIVATE_KEY"
chmod 650 "$PUBLIC_KEY"
chmod 650 "$PRIVATE_KEY"

/healthcheck.sh 2> /dev/null > /dev/null && sleep inf || rm -f "$PUBLIC_KEY" && rm -f "$PRIVATE_KEY" && exit 1
