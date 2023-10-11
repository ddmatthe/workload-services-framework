#!/bin/bash -e
#
# Apache v2 license
# Copyright (C) 2023 Intel Corporation
# SPDX-License-Identifier: Apache-2.0
#

OPTION=${1:-throughput_gated}

PLATFORM=${PLATFORM:-SPR}
WORKLOAD=${WORKLOAD:-video-structure}


if [ ${#TAG} -eq 0 ]; then
    TAG=none
fi

# Logs Setting
DIR="$( cd "$( dirname "$0" )" &> /dev/null && pwd )"
. "$DIR/../../script/overwrite.sh"

CHECK_PKM="false"
CHECK_GATED="false"
OPENVINO_VER=2203
COREFORSTREAMS=1
STREAMNUMBER=1
DETECTION_MODEL="yolon"
DETECTION_INFERENCE_INTERVAL=3
DETECTION_THRESHOLD=0.6
CLASSIFICATION_INFERECE_INTERVAL=3
CLASSIFICATION_OBJECT="vehicle"
DECODER_BACKEND="CPU"
MODEL_BACKEND="CPU"
DOCKER_IMAGE="$DIR/Dockerfile.1.external"

if [ $(echo ${OPTION} | grep "pkm") ]; then

    CHECK_PKM="true"

elif [ $(echo ${OPTION} | grep "gated") ]; then

    CHECK_GATED="true"

else

    CHECK_PKM="false"
    CHECK_GATED="false"
    COREFORSTREAMS=$(echo ${OPTION}|cut -d_ -f2)
    STREAMNUMBER=$(echo ${OPTION}|cut -d_ -f3)
    DETECTION_MODEL=$(echo ${OPTION}|cut -d_ -f4)
    DETECTION_INFERENCE_INTERVAL=$(echo ${OPTION}|cut -d_ -f5)
    DETECTION_THRESHOLD=$(echo ${OPTION}|cut -d_ -f6)
    CLASSIFICATION_INFERECE_INTERVAL=$(echo ${OPTION}|cut -d_ -f7)
    CLASSIFICATION_OBJECT=$(echo ${OPTION}|cut -d_ -f8)
    OPENVINO_VER=$(echo ${OPTION}|cut -d_ -f9)
    DECODER_BACKEND=$(echo ${OPTION}|cut -d_ -f10)
    MODEL_BACKEND=$(echo ${OPTION}|cut -d_ -f11)

fi

if [ -e ${DIR}/Dockerfile.1.internal ]; then
    DOCKER_IMAGE="$DIR/Dockerfile.1.internal"
fi

# Workload Setting
WORKLOAD_PARAMS=(WORKLOAD CHECK_PKM CHECK_GATED COREFORSTREAMS STREAMNUMBER DETECTION_MODEL DETECTION_INFERENCE_INTERVAL DETECTION_THRESHOLD CLASSIFICATION_INFERECE_INTERVAL CLASSIFICATION_OBJECT OPENVINO_VER DECODER_BACKEND MODEL_BACKEND)

# Docker Setting
DOCKER_OPTIONS="--privileged -e CHECK_PKM=${CHECK_PKM} -e CHECK_GATED=${CHECK_GATED} -e COREFORSTREAMS=${COREFORSTREAMS} -e STREAMNUMBER=${STREAMNUMBER} -e DETECTION_MODEL=${DETECTION_MODEL} -e DETECTION_INFERENCE_INTERVAL=${DETECTION_INFERENCE_INTERVAL} -e DETECTION_THRESHOLD=${DETECTION_THRESHOLD} -e CLASSIFICATION_INFERECE_INTERVAL=${CLASSIFICATION_INFERECE_INTERVAL} -e CLASSIFICATION_OBJECT=${CLASSIFICATION_OBJECT} -e DECODER_BACKEND=${DECODER_BACKEND} -e MODEL_BACKEND=${MODEL_BACKEND}"

# Kubernetes Setting
RECONFIG_OPTIONS="-DK_WORKLOAD=${WORKLOAD} -DK_CHECK_PKM=${CHECK_PKM} -DK_CHECK_GATED=${CHECK_GATED} -DK_COREFORSTREAMS=${COREFORSTREAMS} -DK_STREAMNUMBER=${STREAMNUMBER} -DK_DETECTION_MODEL=${DETECTION_MODEL} -DDOCKER_IMAGE=${DOCKER_IMAGE} -DK_DETECTION_INFERENCE_INTERVAL=${DETECTION_INFERENCE_INTERVAL} -DK_DETECTION_THRESHOLD=${DETECTION_THRESHOLD} -DK_CLASSIFICATION_INFERECE_INTERVAL=${CLASSIFICATION_INFERECE_INTERVAL} -DK_CLASSIFICATION_OBJECT=${CLASSIFICATION_OBJECT} -DK_DECODER_BACKEND=${DECODER_BACKEND} -DK_MODEL_BACKEND=${MODEL_BACKEND}"
JOB_FILTER="job-name=benchmark"


. "$DIR/../../script/validate.sh"
