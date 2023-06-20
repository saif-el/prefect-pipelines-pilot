#!/usr/bin/env bash

prefect deployment build ./workflow/main.py:transform_numbers -n transform_numbers -ib ecs-task/play -sb s3/play -p play-pool
prefect deployment apply transform_numbers-deployment.yaml
prefect deployment build ./workflow/main.py:play -n play -ib ecs-task/play -sb s3/play -p play-pool
prefect deployment apply play-deployment.yaml
