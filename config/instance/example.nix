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
    name = "my-example-container";
    user = {
        uid = 1001;
        gid = 1001;
    };
    network.ports = [
        {
            host = "443";
            container = "2443";
            protocol = "tcp";
        }
    ];
    storage.volumes = [
        {
            host = "/srv/container_config";
            container = "/home/service/config";
            readonly = true;
        }
    ];
    limit = {
        cpu = {
            cores = [ 0 ];
            quota = 1.0;
            weight = 1024;
        };
        memory = 1000;
        disk = [
            {
                device = "/dev/sda";
                write = {
                    iops = 5000;
                    speed = 500;
                };
            }
        ];
        bandwidth = 30;
    };
}
