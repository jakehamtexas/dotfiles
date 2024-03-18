#!/usr/bin/env bash
#
docker ps -qa | xargs docker kill | xargs docker rm
