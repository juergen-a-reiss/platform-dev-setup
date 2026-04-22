#!/bin/bash

for i in `ls docker-compose*`
do 
    docker compose -f $i down
done
