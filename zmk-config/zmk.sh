#!/usr/bin/env bash

# Local build support for zmk firmware
#
# Tp generate or update the initial docker image use:
# ./zmk.sh build-docker
#
# Usage: ./zmk.sh board [parameters passed to west build...]
#
# Environment variables:
#   firmware_name: The file name to copy the firmware to in the artifacts folder. Default value: 'zmk'.
# Examples:
#   firmware_name=my_corne_left ./zmk.sh build --board nice_nano_v2 -- -DSHIELD=corne_left
# Builds the corne_left board and outputs the firmware to artifacts/my_corne_left.uf2
#
# Create a shell inside the docker container using:
#   ./zmk.sh bash

_docker() {
  docker run \
    --rm \
    -it \
    -v .:/app/zmk-config \
    -e "firmware_name=${firmware_name:-zmk}" \
    --entrypoint bash \
    zmk-local-dev \
    "$@"
}

_west_build() {
  # if args doesn't contain a '--' then append it to the end
  if [[ "$@" != *"--"* ]]; then
    set -- "$@" --
  fi
  west build \
    "$@" \
    -DZMK_CONFIG=/app/zmk-config/config \
    -DZMK_EXTRA_MODULES=/app/zmk-config
  if [[ $? -eq 0 ]]; then
    echo "Build successful"
    firmware_name=${firmware_name:-zmk}
    mkdir -p /app/zmk-config/artifacts
    if [[ -f build/zephyr/zmk.uf2 ]]; then
      cp build/zephyr/zmk.uf2 /app/zmk-config/artifacts/$firmware_name.uf2
      echo "$firmware_name.uf2 copied to artifacts"
    elif [[ -f build/zephyr/zmk.bin ]]; then
      cp build/zephyr/zmk.bin /app/zmk-config/artifacts/$firmware_name.bin
      echo "$firmware_name.bin copied to artifacts"
    fi
  else
    echo "Build failed"
  fi
}

case $1 in
  "build-docker")
    docker build -t zmk-local-dev .
    exit
    ;;

  "bash")
    _docker
    exit
    ;;

  "build")
    shift
    _docker /app/zmk-config/zmk.sh docker-build "$@"
    exit
    ;;

  "docker-build")
    shift
    _west_build "$@"
    exit
    ;;

  "phrett")
    firmware_name=phrett_left ./zmk.sh build -b nice_nano_v2 -- -DSHIELD='phrett_left nice_view_adapter nice_view'
    firmware_name=phrett_right ./zmk.sh build -b nice_nano_v2 -- -DSHIELD='phrett_right nice_view_adapter nice_view'
    exit
    ;;
esac

