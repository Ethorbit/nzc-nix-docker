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
    SSL_CERT ? null,
    SSL_KEY ? null,
    writeText,
}:

writeText "reload_on_file_change.sh" ''
    #!/bin/sh
    check_changes() {
        echo "Nginx will auto-reload when a config or certificate changes."
        
        inotifywait -m -r \
            -e close_write,modify,attrib,move,create,delete \
            --exclude '\.swp$|.*template.*' \
            /etc/nginx/conf.d/ \
            ${if SSL_CERT != null then SSL_CERT else ""} \
            ${if SSL_KEY != null then SSL_KEY else ""} | while read dir action file; do
                echo "File in $dir changed ($action) - $file, reloading.."
                nginx -t && nginx -s reload
            done

        sleep 1 && check_changes # It should never stop.
    }

    check_changes &
''
