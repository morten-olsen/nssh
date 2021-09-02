#!/bin/bash

if [ $1 == "help" ]; then
  echo "
Run node, npm, yarn etc. commands in a dockerized one-of sandbox to protect against malicious post installs and the likes.
Supports specifying host port mappings, uplifing of environement variables, network mode and using custom images

This mounts the hosts .npmrc and .yarnrc. Use parameters in place of tokens in those to avoid exposing tokens when not needed

USAGE:

- RC=1 ns.sh yarn install
- ENV=\"NODE_ENV\" ns.sh npm run build
- PORTS=\"80,445\" ns.sh node ./src/server.js
- IMAGE=node NETWORK=host ns.sh npm start
  "
  exit
fi

IMAGE="${IMAGE:-node:alpine}"

ENV_ARGS=""
PORTS_ARGS=""
USER_ARGS=""
NETWORK_ARG=""
VOLUME_ARGS=""

if [[ "$RC" == "1" ]]; then
  [ -f "$HOME/.npmrc" ] || touch "$HOME/.npmrc"
  [ -f "$HOME/.yarnrc" ] || touch "$HOME/.yarnrc"

  VOLUME_ARGS="$VOLUME_ARGS -v $HOME/.npmrc:/root/.npmrc:ro"
  VOLUME_ARGS="$VOLUME_ARGS -v $HOME/.yarnrc:/root/.yarnrc:ro"
fi

if [[ ! -z "$NETWORK" ]]; then
  NETWORK_ARG="--network $NETWORK"
fi

if [[ ! -z "$ENV" ]]; then
  IFS=',' read -r -a ENV_LIST <<< "$ENV"


  for i in "${ENV_LIST[@]}"
  do : 
    ENV_ARGS="$ENV_ARGS --env $i=${!i}"
  done
fi

if [[ ! -z "$PORTS" ]]; then
  IFS=',' read -r -a PORTS_LIST <<< "$PORTS"


  for i in "${PORTS_LIST[@]}"
  do : 
    PORTS_ARGS="$PORTS_ARGS -p $i:$i"
  done
fi

docker run -it --rm \
  $PORTS_ARGS \
  $ENV_ARGS \
  $USER_ARG \
  $NETWORK_ARG \
  $VOLUME_ARGS \
  -v "$PWD:/app" \
  --workdir "/app" \
  --entrypoint="" \
  $IMAGE \
  $@
