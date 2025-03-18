#!/bin/bash

usage() {
    echo "Usage: $0 <pull|push> <project_name>"
}

pull_tf_state() {
    echo "Copying terrafrom state into ${PROJECT_PATH}/terraform.tfstate"

    kubectl -n flux-system get secret tfstate-default-${PROJECT} \
        -ojsonpath='{.data.tfstate}' \
        | base64 -d | gzip -d > ${PROJECT_PATH}/terraform.tfstate
}

push_tf_state() {
    read -p "Are you sure you want to push changes for project '${PROJECT}'? (yes/no): " CONFIRMATION
    if [ "$CONFIRMATION" != "yes" ]; then
        echo "Operation aborted."
        exit 1
    fi

    echo "Copying terraform state for ${PROJECT} into kubernetes"

    kubectl create secret \
        generic tfstate-default-${PROJECT} \
        --from-file=tfstate=<(gzip -c $PROJECT_PATH/terraform.tfstate) \
        --dry-run=client -o=yaml \
        | yq e '.metadata.annotations["encoding"]="gzip"' - \
        > /tmp/tfstate-default-${PROJECT}.yaml

    kubectl -n flux-system apply -f tfstate-default-${PROJECT}.yaml

    rm /tmp/tfstate-default-${PROJECT}.yaml
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$#" -ne 2 ]; then
    usage
    exit 1
fi

COMMAND=$1
PROJECT=$2
PROJECT_PATH="${SCRIPT_DIR}/../terraform/${PROJECT}"

if [ "$COMMAND" == "pull" ]; then
    pull_tf_state
elif [ "$COMMAND" == "push" ]; then
    push_tf_state
else
    usage
    exit 1
fi
