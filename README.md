<!-- LICENSE HEADER MANAGED BY add-license-header

Copyright (C) 2026 Ethorbit

This file is part of nZC.

nZC is free software: you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation, either version 3
of the License, or (at your option) any later version.

nZC is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the
GNU General Public License along with nZC.
If not, see <https://www.gnu.org/licenses/>.
-->

# nZC Nix Docker
A collection of containerized projects, built and configured entirely through [Nix](https://nixos.org/).

Designed to overcome all issues encountered from 3 years of operating the [nZC game community](https://nzcservers.com) with Docker.

| | **nZC Nix Docker** | [nZC Docker](https://github.com/Ethorbit/nzc-docker) | [Pterodactyl](https://pterodactyl.io/) |
|--|-----|---------|-------------|
| **Deployment** | [Nix](https://nixos.org/) + [Arion](https://docs.hercules-ci.com/arion/) | [Docker Compose](https://docs.docker.com/compose/) YAML | Web UI |
| **Configuration** | [Nix attribute sets](https://nix.dev/manual/nix/2.18/language/values.html?highlight=attribute%20set#attribute-set) | Environment files | [JSON eggs](https://pterodactyl.io/community/config/eggs/creating_a_custom_egg.html) |
| **Structure** | Independent, isolated [projects](projects/) | [Single large project](https://github.com/Ethorbit/nzc-docker) | Server panels |
| **Scalability** | Each project scales independently | Adding containers increases complexity | Limited to supported game servers |
| **Fault Tolerance** | Projects fail in isolation | One broken config breaks everything | Managed by panel |
| **Reusability** | [DRY](https://en.wikipedia.org/wiki/Don't_repeat_yourself) (templates and shared modules) | Repeated YAML | None, eggs are static |
| **Deployment Script** | Reproducible [Nix](https://nixos.org/) expressions | Fragile Makefile | Managed by panel |
| **Scope** | Anything | Hardcoded Dependencies | Primarily games |

## Requirements

- [Nix](https://nixos.org/) with [flakes](https://wiki.nixos.org/wiki/Flakes) enabled
- [Docker](https://www.docker.com/)

## Notes

Arion is [patched](patches/docker-compose-service.nix.patch) to expose additional Compose options not yet upstream ([#256](https://github.com/hercules-ci/arion/issues/256)):
- `stdin_open`
- `cpuset`
- `cpus`
- `cpu_shares`
- `mem_limit`

## Usage

Each project in [projects/](projects/) is a self-contained [Arion](https://docs.hercules-ci.com/arion/) composition. Projects are deployed independently using Arion from the devShell:

```bash
nix develop
```

Then deploy any project by passing it a project path and your own configuration:

```bash
arion -f ./projects/name -f /path/to/your/configuration up
```

Your configuration file should be a Nix module that sets `nzc.instance`:

```nix
{ ... }: {
    nzc.instance = {
        name = "my-project";
        user = {
            uid = 1000;
            gid = 1000;
        };
        storage.volumes = {
            data.volume = "my_project_data";
        };
        network.ports.http = 8080;
        secrets = {
            "password.admin" = "my-admin-password";
        };
    };
}
```

## Official Deployment

[deployments/nzc](deployments/nzc) is used by the official nZC game community which doubles as a real-world example of how you can use this library at scale.

### Available Projects

| Project | Path |
|---------|------|
| [Garry's Mod](projects/gameserver/gmod/default.nix) | `projects/gameserver/gmod` |
| [SFTP](projects/sftp/default.nix) | `projects/sftp` |
