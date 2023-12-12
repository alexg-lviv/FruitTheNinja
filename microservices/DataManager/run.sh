#!/bin/bash


docker build . -t data-manager
docker run --rm --name data-manager-service -p 8080:80 \
  -e PYTHONUNBUFFERED=1 \
  -v $(pwd)/data/:/app/data/ \
  data-manager
