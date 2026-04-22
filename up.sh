#!/bin/bash

docker compose -f docker-compose-postgres.yaml up -d > logs/postgres.txt 
docker compose -f docker-compose-keycloak.yaml up  -d > logs/keycloak.txt
docker compose -f docker-compose-kafka.yaml up -d > logs/kafka.txt

