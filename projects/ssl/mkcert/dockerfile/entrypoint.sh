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

run_hook() {
    [ -n "$HOOK" ] && [ -x "$HOOK" ] || return 0
    CERT_FILE="$PUBLIC_KEY" \
    KEY_FILE="$PRIVATE_KEY" \
    DOMAIN="$DOMAIN_NAME" \
    CAROOT_DIR="$(mkcert -CAROOT)" \
        "$HOOK" || echo "hook failed, retrying next cycle" >&2
}

if [ ! -f "$PRIVATE_KEY" ] || [ ! -f "$PUBLIC_KEY" ]; then
    mkcert -cert-file "$PUBLIC_KEY" -key-file "$PRIVATE_KEY" \
        "$DOMAIN_NAME" "*.$DOMAIN_NAME" || exit 1
fi

chown mkcert:mkcert "$PUBLIC_KEY"
chown mkcert:mkcert "$PRIVATE_KEY"
chmod 650 "$PUBLIC_KEY"
chmod 650 "$PRIVATE_KEY"

trap 'exit 0' TERM INT

while :; do
    if ! /healthcheck.sh >/dev/null 2>&1; then
        rm -f "$PUBLIC_KEY" "$PRIVATE_KEY"
        exit 1
    fi

    run_hook
    sleep "${CHECK_INTERVAL:-86400}" &
    wait $!
done
