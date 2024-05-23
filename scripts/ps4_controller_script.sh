#!/bin/bash

# Change directory to where docker-compose.yml is located
cd /home/bjorn/git/cps_loki

# Restart the teleop service using docker-compose
docker compose restart teleop
