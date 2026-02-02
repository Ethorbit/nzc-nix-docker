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
## WIP upgrade of [nzc-docker](https://github.com/Ethorbit/nzc-docker)
Designed to overcome all issues encountered from 3 years of operation.

## **DO NOT RUN THIS, IT IS NOT FINISHED!!!!**

### Here's what to expect:
- We will **still be Dockerizing everything**, but deployment will be done through [Nix](https://nixos.org/) | [Arion](https://github.com/hercules-ci/arion) rather than Docker Compose YAML.
 
- Instead of modifying environment files, you will **edit everything in** [Nix attribute sets](https://nix.dev/manual/nix/2.18/language/values.html?highlight=attribute%20set#attribute-set). You will **create project-specific settings using templates**
 
- Each [project](projects/) will be **fully isolated** and **deployed independently** to maximize scalability, maintainability, and fault tolerance.  

This is a **collection** of Dockerized projects that **collectively form nZC**, rather than a [single large Dockerized project](https://github.com/Ethorbit/nzc-docker).

### What Was Wrong with the Previous Infrastructure

The previous infrastructure suffered from several fundamental design issues that made it fragile, hard to scale, and misaligned with Docker best practices:

- **Violation of Docker Philosophy**  
  The project relied on a brittle, centralized configuration model, which goes against Docker’s core principles of modularity, isolation, and composability.

- **Unintuitive Deployment Process**  
  Container deployment was managed via a Makefile script that was difficult to understand and potentially incompatible across different systems.

- **Single Point of Failure**  
  If a user accidentally broke the configuration, *none* of the containers could be deployed, making the entire system fragile.

- **Poor Scalability**  
  Adding additional containers significantly increased complexity, rather than being a straightforward, incremental change.

- **Configuration Is Not Programming**  
  Docker Compose configuration is **not programming**, it’s just standard YAML. Due to the lack of abstraction and reuse features, it was not possible to follow the **DRY** (Don’t Repeat Yourself) principle, causing configurations to become bloated and increasingly hard to maintain.

### Why not Pterodactyl?

Many server admins run Pterodactyl Server, but let me explain why it's not the right solution for nZC

* Pterodactyl is primarily optimized for games, but nZC runs more than just that
* Pterodactyl uses JSON eggs for server definitions, which are declarative but not programmable, carrying the same issues as Docker Compose's YAML.
* Nix + Arion gives **complete control**, allowing infinite possibilites.
* Personal Preference
  * All my systems already run with Nix and they are **rock solid**!
  * I prefer **the CLI** for building and maintaining containers.
