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

{ writeText, PUID, PGID }:

writeText "start.sh" ''
#!/bin/sh

# setup socket
rm /var/run/php-fpm/sock 2> /dev/null
touch /var/run/php-fpm/sock
chown ${PUID}:${PGID} /var/run/php-fpm
chmod 770 /var/run/php-fpm
chown ${PUID}:${PGID} /var/run/php-fpm/sock
chmod 770 /var/run/php-fpm/sock

exec php-fpm
''
