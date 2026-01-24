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

{ settings ? import ../shared.nix }:

{
    project.name = "example";

    services.hello.service = {
        image = "hello-world";

        # Optional: environment variables
        environment = settings.environment or { };

        # Optional: volumes (not needed for hello-world)
        volumes = settings.volumes or [ ];

        # Optional: ports (not needed for hello-world)
        ports = settings.ports or [ ];

        # Optional: build args (not needed, using public image)
        build = settings.build or null;
    };
}
