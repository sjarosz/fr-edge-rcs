#!/bin/bash
#
# Copyright 2019 ForgeRock AS. All Rights Reserved
#
CONNECTOR_SERVER_HOME="${CONNECTOR_SERVER_HOME:-/opt/openicf}"

JAVA_OPTS="${JAVA_OPTS:- -server -XX:MaxRAMPercentage=80 -XshowSettings:vm}"

for P in "$@"
do
  if [ "${P:0:2}" = "-D" ]; then
    OPENICF_OPTS="$OPENICF_OPTS ${P}"
  fi
done

MAIN_CLASS="org.forgerock.openicf.framework.server.Main"
CLASSPATH="$CONNECTOR_SERVER_HOME/lib/framework/*:$CONNECTOR_SERVER_HOME/lib/framework/"

if [ "$1" = "jpda" ] ; then
  if [ -z "$JPDA_TRANSPORT" ]; then
    JPDA_TRANSPORT="dt_socket"
  fi
  if [ -z "$JPDA_ADDRESS" ]; then
    JPDA_ADDRESS="5005"
  fi
  if [ -z "$JPDA_SUSPEND" ]; then
    JPDA_SUSPEND="n"
  fi
  if [ -z "$JPDA_OPTS" ]; then
    JPDA_OPTS="-agentlib:jdwp=transport=$JPDA_TRANSPORT,address=$JPDA_ADDRESS,server=y,suspend=$JPDA_SUSPEND"
  fi
  OPENICF_OPTS="$OPENICF_OPTS $JPDA_OPTS"
  shift
fi

shopt -s nocasematch
if [ "$1" = "--setKey" ]; then
    if [ -n "$2" ]; then
        exec java ${OPENICF_OPTS} -classpath "${CLASSPATH}" \
          $MAIN_CLASS -setKey -key $2 -properties "$CONNECTOR_SERVER_HOME/conf/ConnectorServer.properties"
    else
        exec java ${OPENICF_OPTS} -classpath "${CLASSPATH}" \
          $MAIN_CLASS -setKey -properties "$CONNECTOR_SERVER_HOME/conf/ConnectorServer.properties"
    fi
elif [ "$1" = "--help" ]; then
  exec java ${OPENICF_OPTS} -classpath "${CLASSPATH}" $MAIN_CLASS --help
else
  exec java ${JAVA_OPTS} ${OPENICF_OPTS} \
        -Djava.awt.headless=true \
        -classpath "${CLASSPATH}" \
        $MAIN_CLASS -run \
        -properties "$CONNECTOR_SERVER_HOME/conf/ConnectorServer.properties"
fi
shopt -u nocasematch