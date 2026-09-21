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

{ PORT, writeText }:

writeText "healthcheck.sh" ''
#!/bin/sh

# Let it install.
if [ ! -f "$SERVERS_DIR/.server_installed_successfully" ]; then
    exit 0
fi

# Marker is keyed to PID 1's start time, so it resets on container restart.
MARKER="/tmp/.a2s-reachable-$(cut -d' ' -f22 /proc/1/stat)"
HOST_IP=$(hostname -i | cut -d' ' -f1)

if /usr/local/bin/a2s info "$HOST_IP:${PORT}" >/dev/null 2>&1; then
    touch "$MARKER"
    exit 0
fi

# Never reachable yet means still starting, so don't count it as a failure.
if [ ! -f "$MARKER" ]; then
    exit 0
fi

exit 1
''
