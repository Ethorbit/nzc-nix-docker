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
        mkdir -p $out
        export CAROOT=$TMPDIR/mkcert-ca
        mkdir -p $CAROOT
        HOME=$TMPDIR mkcert -install
        HOME=$TMPDIR mkcert -cert-file $out/certificate.pem -key-file $out/key.pem localhost 127.0.0.1
    '';
in
{
    project = "nginx";
    instance = {
        user = {
            uid = 1200;
            gid = 1200;
        };

        network.ports = {
            http.number = 80;
            https.number = 443;
        };

        secrets = {
            "ssl.certificate" = "${testCert}/certificate.pem";
            "ssl.key" = "${testCert}/key.pem";
        };

        features.php.enabled = true;
        php-fpm.debug = true;

        # their defaults are fine.
        # nginx.config.file
        # nginx.config.serverDirectory

        storage.volumes = {
            websites = {
                volume = "${pkgs.writeTextDir "index.php" ''
                    <!DOCTYPE html>
                    <html>
                    <head>
                        <title>PHP Test</title>
                    </head>
                    <body>
                        <h1><q>Hello World</q> - nzc-nix-docker</h1>

                        <p>Current server time: <?php echo date('Y-m-d H:i:s'); ?></p>

                        <p>PHP version: <?php echo phpversion(); ?></p>

                        <?php
                        $items = ['nginx', 'php-fpm', 'socket'];
                        ?>
                        <ul>
                            <?php foreach ($items as $item): ?>
                                <li><?php echo htmlspecialchars($item); ?></li>
                            <?php endforeach; ?>
                        </ul>

                        <?php if (extension_loaded('pdo_mysql')): ?>
                            <p>pdo_mysql extension is loaded.</p>
                        <?php else: ?>
                            <p>pdo_mysql extension is NOT loaded.</p>
                        <?php endif; ?>
                    </body>
                    </html>
                ''}";
            };
        };
    };
}
