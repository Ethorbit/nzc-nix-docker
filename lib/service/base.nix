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
    resources = instance.resources;
in
{
    container_name = instance.name;

    volumes = map (
        volume: "${volume.host}:${volume.container}${if volume.readonly then ":ro" else ":rw"}"
    ) (instance.volumes ++ (if instance.lxcfs.enable then instance.lxcfs.volumes else []));

    ports = map (
        port: "${builtins.toString port.host}:${builtins.toString port.container}/${port.protocol}"
    ) instance.ports;
} // (if resources.enable then {
    mem_limit = "${builtins.toString resources.memory.limit}M";
    cpuset = builtins.concatStringsSep "," (builtins.map builtins.toString resources.cpu.cores);
    cpus = builtins.toString resources.cpu.quota;
    cpu_shares = builtins.toString resources.cpu.weight;
} else {})
