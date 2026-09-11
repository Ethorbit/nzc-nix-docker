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

ROOT_PASSWORD="$(cat $MYSQL_ROOT_PASSWORD_FILE)"
ADMIN_PASSWORD="$(cat $MYSQL_ADMIN_PASSWORD_FILE)"
[ -n "$ROOT_PASSWORD" ] || { echo "root-password secret is empty" >&2; exit 1; }
[ -n "$ADMIN_PASSWORD" ] || { echo "admin-password secret is empty" >&2; exit 1; }
[ "${#ROOT_PASSWORD}" -le 5 ] && { echo "root-password secret is too short" >&2; exit 1; }
[ "${#ADMIN_PASSWORD}" -le 5 ] && { echo "admin-password secret is too short" >&2; exit 1; }
[ "${#ROOT_PASSWORD}" -ge 256 ] && { echo "root-password secret is too long" >&2; exit 1; }
[ "${#ADMIN_PASSWORD}" -ge 256 ] && { echo "admin-password secret is too long" >&2; exit 1; }

chmod 750 /var/lib/mysql
chown mysql:mysql /var/lib/mysql
exec /usr/local/bin/docker-entrypoint.sh $@
