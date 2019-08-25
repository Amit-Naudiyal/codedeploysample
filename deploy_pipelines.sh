#!/bin/bash
STAGE="stg"
[[ -n "${1}" ]] && { STAGE="${1}"; }
CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${CWD}/pipelines"
PIPELINES=$(ls -1 ${CWD}/pipeline-*.yaml 2>/dev/null)
[[ -z "${PIPELINES}" ]] && { echo "There are no pipelines. Create one"; exit 1; }
declare -a PIPELINE_ARRAY
set -e
for pipeline in $PIPELINES; do
  pipeline_name=$(basename $pipeline .yaml)
  cmd="cd $OUTPUT_DIR/$pipeline_name && serverless deploy -v --force --env=${STAGE}"
  if [[ $pipeline_name = *kickstart* ]]; then
    PIPELINE_ARRAY=("${cmd}" "${PIPELINE_ARRAY[@]}")
  else
    PIPELINE_ARRAY+=("${cmd}")
  fi
done
for ((i = 0; i < ${#PIPELINE_ARRAY[@]}; i++)); do
  echo running: ${PIPELINE_ARRAY[$i]}
  bash -c "${PIPELINE_ARRAY[$i]}"
done
