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

[ -s "$PUBLIC_KEY" ] && [ -s "$PRIVATE_KEY" ] || exit 1
openssl x509 -noout -checkend 604800 -in "$PUBLIC_KEY" >/dev/null 2>&1 || exit 1
[ "$(openssl x509 -noout -pubkey -in "$PUBLIC_KEY" 2>/dev/null)" = \
  "$(openssl pkey -pubout -in "$PRIVATE_KEY" 2>/dev/null)" ] || exit 1
