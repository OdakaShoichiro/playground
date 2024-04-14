#!/usr/bin/bash

jupyter lab \
    --no-browser \
    --gpus all \
    --ip 0.0.0.0 \
    --port 8888 \
    --NotebookApp.token='' \
    --notebook-dir='/workspace/notebook'
