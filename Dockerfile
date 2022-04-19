#
#  Copyright 2019-2020 ForgeRock AS. All Rights Reserved
#
#  Use of this code requires a commercial software license with ForgeRock AS.
#  or with one of its affiliates. All use shall be exclusively subject
#  to such license between the licensee and ForgeRock AS.
#
FROM gcr.io/forgerock-io/java-11:latest
#
# Default install directory for IG. Override this to set a different location.
#
ENV INSTALL_DIR /opt/openicf

COPY . "${INSTALL_DIR}"

RUN chmod 777 /opt/openicf/csv.csv


RUN mkdir -p /opt/openicf/logs
RUN chmod -R 777 /opt/openicf/logs
WORKDIR /opt/openicf


USER 11111


#CMD ["sh", "-c", "tail -f /dev/null"]
ENTRYPOINT "bin/docker-entrypoint.sh"
