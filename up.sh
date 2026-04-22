#!/bin/bash

if [ ! -f components ]; then
  cp components.template components
fi

COMPOSE_PROFILES=$(paste -sd, components) docker compose up -d
