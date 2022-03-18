#!/bin/bash
#
# Copyright 2014-2017 ForgeRock AS. All Rights Reserved
#
# Use of this code requires a commercial software license with ForgeRock AS.
# or with one of its affiliates. All use shall be exclusively subject
# to such license between the licensee and ForgeRock AS.
#
# clean up left over pid files if necessary
cleanupPidFile() {
  if [ -f "$OPENICF_PID_FILE" ]; then
    rm -f "$OPENICF_PID_FILE"
  fi
  trap - EXIT
  exit
}

main_exec(){
    exec $JAVA $OPENICF_OPTS -classpath "$CLASSPATH" \
     $MAIN_CLASS $1 -properties "$CONNECTOR_SERVER_HOME/conf/ConnectorServer.properties"
}

service_exec(){
    # Keep track of this pid
    echo $$ > "$OPENICF_PID_FILE"
    echo "OPENICF_OPTS:   "$OPENICF_OPTS
    echo "CLASSPATH:      "$CLASSPATH
    exec $JAVA $OPENICF_OPTS -server -classpath "$CLASSPATH" \
        $MAIN_CLASS $1 -properties "$CONNECTOR_SERVER_HOME/conf/ConnectorServer.properties"
}

usage(){
    echo "Usage: ConnectorServer <command> [option], where command is one of the following:"
    echo "   /run [\"-J<java option>\"] - Runs the server from the console."
    echo "   /setKey [<key>] - Sets the connector server key."
    echo "   /setDefaults - Sets the default ConnectorServer.properties."
    echo
    echo "example:"
    echo "    ConnectorServer.sh /run \"-J-Djavax.net.ssl.keyStore=mykeystore.jks\" \"-J-Djavax.net.ssl.keyStorePassword=changeit\""
    echo "       - this will run connector server with SSL"
    echo
    echo "    ConnectorServer.sh jpda /run"
    echo "       - this will run connector server in debug mode"
}

# Set Connector Server Home
# resolve links - $0 may be a softlink
PRG="$0"

while [ -h "$PRG" ]; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

# Get standard environment variables
PRGDIR=`dirname "$PRG"`

# Only set CONNECTOR_SERVER_HOME if not already set
[ -z "$CONNECTOR_SERVER_HOME" ] && CONNECTOR_SERVER_HOME=`(cd "$PRGDIR/.." >/dev/null; pwd)`

if [ ! -f "$CONNECTOR_SERVER_HOME/bin/ConnectorServer.sh" ]; then
    echo Invalid CONNECTOR_SERVER_HOME environment variable
    echo Please set it to correct Connector Server Home
    exit 1
fi

# Make the script location the current directory
cd "$CONNECTOR_SERVER_HOME"

# Only set OPENICF_PID_FILE if not already set
[ -z "$OPENICF_PID_FILE" ] && OPENICF_PID_FILE="$CONNECTOR_SERVER_HOME"/.openicf.pid

# Only set OPENICF_OPTS if not already set
[ -z "$OPENICF_OPTS" ] && OPENICF_OPTS="-Xmx512m"

for P in "$@"
do
  if [ "${P:0:2}" = "-J" ]; then
    OPENICF_OPTS="$OPENICF_OPTS ${P##-J}"
  fi    
done

# Check Java availability
if type -p 'java' >/dev/null; then
    JAVA=java
elif [ -n "$JAVA_HOME" ] && [ -x "$JAVA_HOME/bin/java" ];  then
    JAVA="$JAVA_HOME/bin/java"
else
    echo JAVA_HOME not available, Java is needed to run the Connector Server
    echo Please install Java and set the JAVA_HOME accordingly
    exit 1
fi

MAIN_CLASS=org.forgerock.openicf.framework.server.Main
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
if [ "$1" = "/run" ]; then
      service_exec -run
elif [ "$1" = "/start" ]; then
      service_exec -service
elif [ "$1" = "/setDefaults" ]; then
      main_exec -setDefaults
elif [ "$1" = "/setKey" ]; then
    if [ -n "$2" ]; then
        exec $JAVA $OPENICF_OPTS -classpath "$CLASSPATH" \
          $MAIN_CLASS -setKey -key $2 -properties "$CONNECTOR_SERVER_HOME/conf/ConnectorServer.properties"      
    else
        exec $JAVA $OPENICF_OPTS -classpath "$CLASSPATH" \
          $MAIN_CLASS -setKey -properties "$CONNECTOR_SERVER_HOME/conf/ConnectorServer.properties"   
    fi      
else
      usage
fi
shopt -u nocasematch
