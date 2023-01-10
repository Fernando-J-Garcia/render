#!/usr/bin/env bash
set -e

echo "Deploying server."

# Source environment variables (needed for $PROJECT_ID)
. .env

# Path to where the container will be uploaded. We use gcr.io (Google Container Registry)
DOCKER_IMAGE=gcr.io/${PROJECT_ID}/prerender
# Container version (e.g. "2021.02.03_11.15.30")
VERSION=$(date +"%Y.%m.%d_%H.%M.%S")

# Compile code.
#(cd src; npm install && npm run build)
(cd src; npm install)

# Build Docker image. We navigate up to our parent directory so that we can include the shared/ library.
docker build -t ${DOCKER_IMAGE}:latest -t ${DOCKER_IMAGE}:"${VERSION}" --progress=plain -f ./Dockerfile .

# Deploy to container registry. If this fails, you may need to run the below command:
#  gcloud auth configure-docker
docker push ${DOCKER_IMAGE}:"${VERSION}"
docker push ${DOCKER_IMAGE}:latest

# Replace environment variables in fleet.yaml and update our fleet with the latest image.
export DOCKER_IMAGE="${DOCKER_IMAGE}:${VERSION}"
envsubst < ./server.yaml | kubectl apply -f -
