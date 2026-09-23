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

{ ... }:

{
    project = "ssl/mkcert";
    module = { pkgs, ... }: {
        config = {
            nzc.instance = {
                user = {
                    uid = 1100;
                    gid = 1100;
                };

                mkcert = {
                    domainName = "local.internal";
                    checkInterval = 10;
                };

                storage.volumes = {
                    certificates.volume = "certificates";

                    # You can copy the cert for several users and use it in other projects.
                    script.volume = "${pkgs.writeScript "hook" ''
                    #!/bin/sh
                    set -eu

                    changes_made=0

                    for entry in 1000:1000 2000:2000; do
                        uid=$(echo "$entry" | cut -d: -f1)
                        gid=$(echo "$entry" | cut -d: -f2)

                        new_cert="/mnt/$uid-$gid-mkcert.pem"
                        new_key="/mnt/$uid-$gid-mkcert.key"

                        # Stop here if the new certificate already exists 
                        # and matches mkcert's latest certificate
                        if [ -f "$new_cert" ] && [ -f "$new_key" ]; then
                            if cmp -s "$CERT_FILE" "$new_cert" &&
                                cmp -s "$KEY_FILE" "$new_key"; then
                                continue
                            fi
                        fi

                        install -o "$uid" -g "$gid" -m 644 "$CERT_FILE" "/tmp/.fullchain.tmp"
                        install -o "$uid" -g "$gid" -m 640 "$KEY_FILE" "/tmp/.privkey.tmp"
                        mv /tmp/.fullchain.tmp "$new_cert"
                        mv /tmp/.privkey.tmp "$new_key"

                        changes_made=1
                    done

                    if [ "$changes_made" -eq 1 ]; then
                        echo "Script made changes for: $DOMAIN!"
                    fi
                    ''}";
                };
            };
        };
    };
}
