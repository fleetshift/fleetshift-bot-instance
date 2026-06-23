#!/bin/bash
set -e

cd "$(dirname "$0")"

git submodule update --init --recursive

echo "Building fleetshift-bot-instance..."
docker build -f dev-bot/Dockerfile.runner -t fleetshift-bot-instance:local .

echo "Done. Image: fleetshift-bot-instance:local"
