#!/usr/bin/env bash
set -euo pipefail

# Set directories relative to the app_home directory
APP_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )
BIN_DIR="$APP_HOME/bin"
LIB_DIR="$APP_HOME/lib"
CONFIG_DIR="$APP_HOME/config"

# File paths
JAR="$LIB_DIR/pension-api-fat.jar"
CONF="$CONFIG_DIR/config.json"
LOG="$CONFIG_DIR/log4j2.xml"
OPTIONS="$CONFIG_DIR/options.json"
CLUSTER_CONFIG="$CONFIG_DIR/cluster.xml"

# JMX configuration
JMX_PORT=7777
JMX_DOMAIN="pension"

# JVM options for logging and metrics
LOGGING_OPTS=(
  "-Dvertx.logger-delegate-factory-class-name=io.vertx.core.logging.Log4j2LogDelegateFactory"
  "-Dlog4j.configurationFile=$LOG"
)

# Hazelcast-specific JVM options
HAZELCAST_OPTS=(
  "-Dvertx.hazelcast.config=$CLUSTER_CONFIG"
  "-Dhazelcast.logging.type=log4j2"
)

# General JVM options
GENERAL_OPTS=(
  "-XX:+HeapDumpOnOutOfMemoryError"
  "-XX:+ShowCodeDetailsInExceptionMessages"
)

# JMX-specific JVM options
JMX_OPTS=(
  "-Dcom.sun.management.jmxremote"
  "-Dcom.sun.management.jmxremote.port=$JMX_PORT"
  "-Dcom.sun.management.jmxremote.local.only=false"
  "-Dcom.sun.management.jmxremote.authenticate=false"
  "-Dcom.sun.management.jmxremote.ssl=false"
)

# Module and export options for Java
MODULE_OPTS=(
  "--add-modules java.se"
  "--add-exports java.base/jdk.internal.ref=ALL-UNNAMED"
  "--add-opens java.base/java.lang=ALL-UNNAMED"
  "--add-opens java.base/java.nio=ALL-UNNAMED"
  "--add-opens java.base/sun.nio.ch=ALL-UNNAMED"
  "--add-opens java.management/sun.management=ALL-UNNAMED"
  "--add-opens jdk.management/com.sun.management.internal=ALL-UNNAMED"
)

# Move to the app_home directory to execute
cd "$APP_HOME"

# Echo JVM options for debugging
echo "JVM Options: ${LOGGING_OPTS[@]} ${HAZELCAST_OPTS[@]} ${GENERAL_OPTS[@]} ${JMX_OPTS[@]}"

# Run the Java application
java \
  ${LOGGING_OPTS[@]} \
  ${HAZELCAST_OPTS[@]} \
  ${GENERAL_OPTS[@]} \
  ${JMX_OPTS[@]} \
  ${MODULE_OPTS[@]} \
  -classpath "$LIB_DIR/*:$JAR:lib" \
  io.vertx.core.Launcher run com.tamal.pension.api.Server \
  -options "$OPTIONS" \
  -conf "$CONF" \
  -cluster