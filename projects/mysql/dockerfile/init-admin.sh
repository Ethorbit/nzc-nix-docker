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

set -e

echo "$MYSQL_ADMIN_NAME" | grep -Eq '^[A-Za-z_][A-Za-z0-9_]*$' || { echo "Invalid MYSQL_ADMIN_NAME" >&2; exit 1; }

ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD"
ADMIN_PASSWORD="$(cat $MYSQL_ADMIN_PASSWORD_FILE)"

CREDS_PIPE="$(mktemp -u)"
mkfifo -m 600 "$CREDS_PIPE"
trap 'rm -f "$CREDS_PIPE"' EXIT

printf '[client]\nuser=root\npassword=%s\n' "$ROOT_PASSWORD" > "$CREDS_PIPE" &

mysql --defaults-extra-file="$CREDS_PIPE" <<-EOSQL
    DROP USER 'root'@'%';
    CREATE USER IF NOT EXISTS '$MYSQL_ADMIN_NAME'@'%' IDENTIFIED BY '$ADMIN_PASSWORD';
    GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_ADMIN_NAME'@'%';
    FLUSH PRIVILEGES;
EOSQL
