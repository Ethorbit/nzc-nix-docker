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
* We will **still be Dockerizing everything**, but deployment will be done through [Nix](https://nixos.org/) | [Arion](https://github.com/hercules-ci/arion) rather than Docker Compose YAML.
 
* Instead of modifying environment files, you will edit everything in [Nix attribute sets](https://nix.dev/manual/nix/2.18/language/values.html?highlight=attribute%20set#attribute-set).
 
* Project Roles will be **totally isolated** and **deployed separately** for maximum scalability
  * Game
    * Garry's Mod Project
    * Sven Co-op Project
    * etc.
  * Webserver
    * Nginx Project
    * PHP Project
  * MySQL Database Project
  * Website
    * Portainer Project
    * PHPMyAdmin Project

You choose which roles your node needs. This is **basically a glorified collection of container projects that nZC uses**.

### What was wrong with the previous infrastructure:
* The deployment was **Centralized**, where a single command brought up the entire infrastructure

This on paper appeared to be a brilliant idea for a game community such as **nZC**, however it

1: actually made it hard to scale. The more services we had, the more nightmarish it was to add more. Eventually, I was demotivated from expanding the cluster altogether due to the horrid configuration.

2: caused problems with resource usage as we were expected to run everything on a single machine.

* Docker compose configuration is **not programming**, it's just your standard YAML. Due to lack of features, it was not possible to follow the **DRY** (Don't Repeat Yourself) rule and my configs inevitably became bloated and hard to maintain as a consequence.

### Why not Pterodactyl?

Many server admins run Pterodactyl Server, but let me explain why it's not the right solution for nZC

* Pterodactyl is primarily optimized for games, but nZC runs more than just that
* Pterodactyl uses JSON eggs for server definitions, which are declarative but not programmable, carrying the same issues as Docker Compose's YAML.
* Nix + Arion gives **complete control**, allowing infinite possibilites.
* Personal Preference
  * All my systems already run with Nix and they are **rock solid**!
  * I prefer **the CLI** for building and maintaining containers.
