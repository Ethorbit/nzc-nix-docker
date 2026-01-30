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

{ lib, config }:

let
    instance = config.instance;
in
{
    container_name = instance.name;

    volumes = let
        storage = instance.storage;
        lxcfs = storage.lxcfs;
    in map (
        volume: "${volume.host}:${volume.container}${if volume.readonly then ":ro" else ":rw"}"
    ) (storage.volumes ++ (if lxcfs.enable then lxcfs.volumes else []));

    ports = map (
        port: "${toString port.host}:${toString port.container}/${port.protocol}"
    ) instance.network.ports;

    labels = instance.labels // (if instance.limit.enable then {
        "com.docker-tc.enabled" = "1";
        "com.docker-tc.limit" = "${toString instance.limit.bandwidth}mbps";
    } else {});
} // (if instance.limit.enable then 
let
    limit = instance.limit;
in {
    cpuset = builtins.concatStringsSep "," (map toString limit.cpu.cores);
    cpus = toString limit.cpu.quota;
    cpu_shares = toString limit.cpu.weight;
    mem_limit = "${toString limit.memory.limit}M";

    blkio_config = let
        disk = limit.disk;
    in if disk != [] then {
        device_read_bps = map (disk: {
            path = disk.device;
            rate = "${toString disk.read.speed}mb";
        }) disk;
        device_write_bps = map (disk: {
            path = disk.device;
            rate = "${toString disk.write.speed}mb";
        }) disk;
        device_read_iops = map (disk: {
            path = disk.device;
            rate = disk.read.iops;
        }) disk;
        device_write_iops = map (disk: {
            path = disk.device;
            rate = disk.write.iops;
        }) disk;
    } else {};
} else {})
