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

# nZC Deployments

Manages nZC game server infrastructure using [nzc-nix-docker](https://github.com/Ethorbit/nzc-nix-docker).

## Requirements

- Nix with flakes enabled
- Docker

## Configuration

Instances are defined in `config/`. Each instance specifies a project type and its settings.

To add or modify instances, edit the relevant file in `config/` (e.g. `config/gmod.nix`).

## Usage

List available instances:
```bash
nix flake show
```

Run arion commands across all instances:
```bash
nix run .#all -- up -d
nix run .#all -- down
nix run .#all -- ps
```

Run arion commands on a specific instance:
```bash
nix run .#gmod_1 -- up -d
nix run .#gmod_1 -- down
```
