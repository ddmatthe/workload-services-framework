#!/bin/bash -e
#
# Apache v2 license
# Copyright (C) 2023 Intel Corporation
# SPDX-License-Identifier: Apache-2.0
#

CONFIG=${1:-qat-rsa}
WORKLOAD=${WORKLOAD:-openssl3_rsamb_qatsw}
PLATFORM=${PLATFORM:-SPR}
ASYNC_JOBS=${ASYNC_JOBS:-64}
PROCESSES=${PROCESSES:-8}
BIND_CORE=${BIND_CORE:-1c1t}
BIND=${BIND:-false}
MODE=${CONFIG/-*/}
ALGORITHM=$(echo $CONFIG | cut -f2- -d-)

# Logs Setting
DIR="$( cd "$( dirname "$0" )" &> /dev/null && pwd )"
. "$DIR/../../script/overwrite.sh"

# Workload Setting
MODE="${CONFIG/-*/}"
ALGORITHM="$(echo $CONFIG | cut -f2- -d-)"
WORKLOAD_PARAMS=(MODE ALGORITHM)

# Docker Setting
if [[ "$CONFIG" = qathw* ]] && [ "$BACKEND" != "@pve" ]; then
    DOCKER_IMAGE=""
    DOCKER_OPTIONS=""
else
    DOCKER_IMAGE="$DIR/Dockerfile.2.${WORKLOAD/*_/}"
    DOCKER_OPTIONS="--privileged -v /dev/hugepages/qat:/dev/hugepages/qat -e CONFIG=$CONFIG"
fi

# Kubernetes Setting
RECONFIG_OPTIONS="-DCONFIG=$CONFIG -DASYNC_JOBS=$ASYNC_JOBS -DPROCESSES=$PROCESSES -DBIND_CORE=$BIND_CORE -DBIND=$BIND"
JOB_FILTER="job-name=benchmark"

# Script args
SCRIPT_ARGS="$TESTCASE"

. "$DIR/../../script/validate.sh"
