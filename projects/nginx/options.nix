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

{ config, pkgs, lib, ... }:

{
    options = with lib; {
        nzc = {
            instance = {
                nginx = {
                    config = {
                        file = mkOption {
                            type = types.nullOr types.path;
                            default = pkgs.callPackage ./app-config/nginx/nginx.conf.nix {};
                        };
                        
                        serverDirectory = mkOption {
                            type = types.nullOr types.path;
                            default = pkgs.callPackage ./app-config/nginx/conf.d.default.nix {
                                key = config.nzc.instance.secrets."ssl.key";
                                certificate = config.nzc.instance.secrets."ssl.certificate";
                            };
                        };

                        snippets = mkOption {
                            type = types.nullOr types.path;
                            default = null;
                        };
                    };
                };

                php-fpm = {
                    config = {
                        www = mkOption {
                            type = types.nullOr types.path;
                            default = ./app-config/php-fpm/www.conf;
                        };

                        ini = mkOption {
                            type = types.nullOr types.path;
                            default = (pkgs.callPackage ./app-config/php-fpm/php.ini.nix {
                                debug = config.nzc.instance.php-fpm.debug;
                            });
                        };
                    };

                    debug = mkOption {
                        description = "Toggle error verbosity to debug PHP script problems.";
                        type = types.bool;
                        default = false;
                        example = true;
                    };

                    extensions = mkOption {
                        description = "PHP extensions to enable for this instance";
                        type = types.listOf types.str;
                        default = [
                            "opcache"
                            "mysqli"
                            "mbstring"
                            "zip"
                            "simplexml"
                            "xmlwriter"
                            "xml"
                            "bcmath"
                            "pdo"
                            "pdo_mysql"
                        ];
                        example = [ "mysqli" "mbstring" "zip" ];
                    };

                    packages = mkOption {
                        description = "Alpine packages to install for this instance";
                        type = types.listOf types.str;
                        default = [
                            "php-openssl"
                            "php-curl"
                            "php-tokenizer"
                            "oniguruma-dev"
                            "libzip-dev"
                            "libxml2-dev"
                        ];
                        example = [ "libzip-dev" "oniguruma-dev" ];
                    };
                };
            };
        };
    };
}
