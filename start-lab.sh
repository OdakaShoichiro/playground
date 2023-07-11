#!/usr/bin/bash

jupyter lab /workspace/notebook \
    --no-browser \
    --allow-root \
    --gpus all \
    --ip 0.0.0.0 \
    --port 8888 \
