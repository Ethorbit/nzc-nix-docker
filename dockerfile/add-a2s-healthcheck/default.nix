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
    A2S_VERSION ? "0.3.2",
    ALPINE_IMAGE_TAG ? "3.24.2",
    PORT,
    context,
    interval ? "15s",
    timeout ? "5s",
    startPeriod ? "10s",
    retries ? 5,
    writeText,
    runCommand,
    callPackage
}:
let
    Dockerfile = writeText "Dockerfile" ''
        FROM alpine:${ALPINE_IMAGE_TAG} AS a2s
        ARG A2S_VERSION=${A2S_VERSION}
        ENV PORT=${PORT}
        COPY a2s/healthcheck.sh /healthcheck.sh
        RUN chmod +x /healthcheck.sh &&\
            wget -q -O /usr/local/bin/a2s \
                https://github.com/WoozyMasta/a2s/releases/download/v${A2S_VERSION}/a2s-linux-amd64 &&\
            chmod +x /usr/local/bin/a2s
        ENTRYPOINT [ "/usr/local/bin/a2s" ]

        ${builtins.readFile "${context}/Dockerfile"}
        COPY --from=a2s /usr/local/bin/a2s /usr/local/bin/a2s
        COPY --from=a2s /healthcheck.sh /a2s-healthcheck.sh
        HEALTHCHECK \
            --interval=${interval} \
            --timeout=${timeout} \
            --start-period=${startPeriod} \
            --retries=${toString retries} \
            CMD /a2s-healthcheck.sh
    '';

    healthcheck = (callPackage ./healthcheck.sh.nix { inherit PORT; });
in
runCommand "docker-context" {} ''
    mkdir -p $out
    cp -a ${context}/. $out/
    chmod -R u+w $out
    mkdir -p $out/a2s
    cp ${healthcheck} $out/a2s/healthcheck.sh
    cp ${Dockerfile} $out/Dockerfile
''
