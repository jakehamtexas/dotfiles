#!/usr/bin/env bash

# Check for gcloud docker image

GCLOUD_DOCKER_IMAGE="gcr.io/google.com/cloudsdktool/google-cloud-cli"
TAG="latest"

update_gcloud_docker() {
	docker pull "$GCLOUD_DOCKER_IMAGE":"$TAG"
}

check_gcloud_docker() {
	if ! docker images | grep -q "$GCLOUD_DOCKER_IMAGE"; then
		echo "gcloud docker image not found. Pulling..."
		update_gcloud_docker
	fi
}

AUTH_CONTAINER_NAME="gcloud_auth"

auth_gcloud() {
	# The gcloud container will store the credentials in a volume that can be reused by other containers
	docker run -ti --name "$AUTH_CONTAINER_NAME" "$GCLOUD_DOCKER_IMAGE":"$TAG" gcloud auth login
}

gcloud() {
	docker run --rm \
		--volumes-from "$AUTH_CONTAINER_NAME" \
		--name gcloud \
		"$GCLOUD_DOCKER_IMAGE":"$TAG" \
		gcloud "$@"
}
