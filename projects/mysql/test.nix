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

{ pkgs, ... }:

let
    testCert = pkgs.runCommand "test-cert" {
        nativeBuildInputs = [ pkgs.mkcert pkgs.nssTools ];
    } ''
        set -e
        mkdir -p $out
        export CAROOT=$TMPDIR/mkcert-ca
        mkdir -p $CAROOT
        HOME=$TMPDIR mkcert -install
        HOME=$TMPDIR mkcert -cert-file $out/certificate.pem -key-file $out/key.pem localhost 127.0.0.1
    '';
in
{
    project = "mysql";
    module = { pkgs, ... }: {
        nzc.instance = {
            user = {
                uid = 4000;
                gid = 4000;
            };

            network.ports = {
                mysql.number = 3306;
                http.number = 8080;
                https.number = 8443;
            };

            features = {
                phpmyadmin.enabled = true;
                backups.enabled = true;
            };

            # The default is fine.
            # phpmyadmin.config

            backup = {
                intervalDays = 7;
                maxBackups = 26;
                compressionLevel = 9;
            };

            secrets = {
                "root.password" =
                    pkgs.writeText "password" ''
                        testpassword
                    '';
                "admin.password" = 
                    pkgs.writeText "password" ''
                        testpassword
                    '';

                "phpmyadmin.blowfish" =
                    pkgs.writeText "blowfish-secret" ''
                        ${builtins.readFile 
                            (pkgs.runCommand 
                                "gen-blowfish"
                                {}
                                "${pkgs.openssl}/bin/openssl rand -base64 24 | tr -d '\n' > $out")}
                '';

                "ssl.certificate" = "${testCert}/certificate.pem";
                "ssl.key" = "${testCert}/key.pem";
            };
        };
    };
}
