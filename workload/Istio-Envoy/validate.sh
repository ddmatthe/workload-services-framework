#!/bin/bash -e
# define the workload arguments
#
# Apache v2 license
# Copyright (C) 2023 Intel Corporation
# SPDX-License-Identifier: Apache-2.0
#
WORKLOAD=${WORKLOAD:-Istio-Envoy}
MODE=${1:-RPS-MAX}
PROTOCOL=${2:-http1}
CRYPTO_ACC=${3:-none}
NODES=${4:-2n}

AUTO_EXTEND_INPUT=${AUTO_EXTEND_INPUT:-false}

ISTIO_VERSION=${ISTIO_VERSION:-1.16.0}

# Nighthawk server cluster configuration 
SERVER_IP=${SERVER_IP} 
SERVER_PORT=${SERVER_PORT:-32222}
SERVER_REPLICA_NUM=${SERVER_REPLICA_NUM:-15}
SERVER_DELAY_MODE=${SERVER_DELAY_MODE:-dynamic}
SERVER_DELAY_SECONDS=${SERVER_DELAY_SECONDS:-0.5} # Only applicable when in static delay mode
SERVER_RESPONSE_SIZE=${SERVER_RESPONSE_SIZE:-10}
SERVER_INGRESS_GW_CPU=${SERVER_INGRESS_GW_CPU:-8}
SERVER_INGRESS_GW_MEM=${SERVER_INGRESS_GW_MEM:-8Gi}
SERVER_INGRESS_GW_CONCURRENCY=${SERVER_INGRESS_GW_CONCURRENCY:-8}
CY_NUM=${CY_NUM:-1}
# Nighthawk client configuration
# Common setting for both http1 & http2 & https
CLIENT_HOST_NETWORK=${CLIENT_HOST_NETWORK:-true}
CLIENT_CPU=${CLIENT_CPU:-8-47}
CLIENT_CONNECTIONS=${CLIENT_CONNECTIONS:-1000}
CLIENT_CONCURRENCY=${CLIENT_CONCURRENCY:-auto}
CLIENT_RPS=${CLIENT_RPS:-10}
CLIENT_RPS_MAX=${CLIENT_RPS_MAX:-300}
CLIENT_RPS_STEP=${CLIENT_RPS_STEP:-10}
CLIENT_LATENCY_BASE=${CLIENT_LATENCY_BASE:-50}

# Setting for http2
CLIENT_MAR=${CLIENT_MAR:-500}
CLIENT_MCS=${CLIENT_MCS:-100}

CLIENT_MRPC=${CLIENT_MRPC:-7}
CLIENT_MPR=${CLIENT_MPR:-100}
CLIENT_RBS=${CLIENT_RBS:-400}


# EMON capture range
EVENT_TRACE_PARAMS="roi,start of region,end of region"

if [[ "${TESTCASE}" =~ "1n" ]]; then
    NODES=1n
fi

if [[ "${TESTCASE}" =~ "aws" ||
      "${TESTCASE}" =~ "gcp" ||
      "${TESTCASE}" =~ "azure" || 
      "${TESTCASE}" =~ "tencent" || 
      "${TESTCASE}" =~ "alicloud" ||
      "${TESTCASE}" =~ "gated" ]]; then
    SERVER_REPLICA_NUM=2
    SERVER_DELAY_MODE=dynamic
    SERVER_DELAY_SECONDS=0.5 # Only applicable when in static delay mode
    SERVER_RESPONSE_SIZE=10
    SERVER_INGRESS_GW_CPU=2
    SERVER_INGRESS_GW_MEM=2Gi
    SERVER_INGRESS_GW_CONCURRENCY=2

    # Nighthawk client configuration
    # Entry level setting for both http1 & http2 & https, just for function valiation. Please make sure the core number in the env is greater than 10
    CLIENT_CPU=10
    CLIENT_CONNECTIONS=10
    CLIENT_CONCURRENCY=auto
    CLIENT_RPS=100
    CLIENT_RPS_MAX=200
    CLIENT_RPS_STEP=100
    CLIENT_LATENCY_BASE=50

    # Setting for http2
    CLIENT_MAR=50
    CLIENT_MCS=10

    CLIENT_MRPC=7
    CLIENT_MPR=100
    CLIENT_RBS=400
fi

CLIENT_CPU=${CLIENT_CPU//","/"!"}

# Logs Setting
DIR="$( cd "$( dirname "$0" )" &> /dev/null && pwd )"
. "$DIR/../../script/overwrite.sh"

if [[ "${CLIENT_HOST_NETWORK}" == "false" ]]; then
    SERVER_PORT=10000
    if [[ "${TESTCASE}" =~ "https" ]]; then
        SERVER_PORT=443
    fi
fi

# Workload Setting
WORKLOAD_PARAMS=(MODE PROTOCOL NODES ISTIO_VERSION SERVER_IP SERVER_PORT SERVER_REPLICA_NUM SERVER_DELAY_MODE SERVER_DELAY_SECONDS SERVER_RESPONSE_SIZE SERVER_INGRESS_GW_CPU SERVER_INGRESS_GW_MEM SERVER_INGRESS_GW_CONCURRENCY CY_NUM CLIENT_CPU CLIENT_CONNECTIONS CLIENT_CONCURRENCY CLIENT_RPS CLIENT_RPS_MAX CLIENT_RPS_STEP CLIENT_MAR CLIENT_MCS CLIENT_LATENCY_BASE CLIENT_HOST_NETWORK CRYPTO_ACC AUTO_EXTEND_INPUT CLIENT_MRPC CLIENT_MPR CLIENT_RBS)

# Docker Setting set as empty since this workload doesn't support Docker backend.
DOCKER_IMAGE=""
DOCKER_OPTIONS=""

# Kubernetes Setting
RECONFIG_OPTIONS="
-DMODE=$MODE
-DPROTOCOL=$PROTOCOL
-DNODES=$NODES
-DISTIO_VERSION=$ISTIO_VERSION
-DSERVER_IP=$SERVER_IP
-DSERVER_PORT=$SERVER_PORT
-DSERVER_REPLICA_NUM=$SERVER_REPLICA_NUM
-DSERVER_DELAY_MODE=$SERVER_DELAY_MODE
-DSERVER_DELAY_SECONDS=$SERVER_DELAY_SECONDS
-DSERVER_RESPONSE_SIZE=$SERVER_RESPONSE_SIZE
-DSERVER_INGRESS_GW_CPU=$SERVER_INGRESS_GW_CPU
-DSERVER_INGRESS_GW_MEM=$SERVER_INGRESS_GW_MEM
-DSERVER_INGRESS_GW_CONCURRENCY=$SERVER_INGRESS_GW_CONCURRENCY
-DCY_NUM=$CY_NUM
-DCLIENT_CPU=$CLIENT_CPU
-DCLIENT_CONNECTIONS=$CLIENT_CONNECTIONS
-DCLIENT_CONCURRENCY=$CLIENT_CONCURRENCY
-DCLIENT_RPS=$CLIENT_RPS
-DCLIENT_RPS_MAX=$CLIENT_RPS_MAX
-DCLIENT_RPS_STEP=$CLIENT_RPS_STEP
-DCLIENT_LATENCY_BASE=$CLIENT_LATENCY_BASE
-DCLIENT_MAR=$CLIENT_MAR
-DCLIENT_MCS=$CLIENT_MCS
-DCLIENT_HOST_NETWORK=$CLIENT_HOST_NETWORK
-DCRYPTO_ACC=$CRYPTO_ACC
-DAUTO_EXTEND_INPUT=$AUTO_EXTEND_INPUT
-DCLIENT_MRPC=$CLIENT_MRPC
-DCLIENT_MPR=$CLIENT_MPR
-DCLIENT_RBS=$CLIENT_RBS
"

JOB_FILTER="job-name=nighthawk-client"

# Let the common validate.sh takes over to manage the workload execution.
. "$DIR/../../script/validate.sh"
