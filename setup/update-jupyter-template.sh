#!/usr/bin/bash

# Tex 出力時のフォントを日本語対応のものに変更
sed -i \
    's/\\documentclass\[11pt\]{article}/\\documentclass[xelatex,ja=standard]{bxjsarticle}/g' \
    /workspace/.venv/share/jupyter/nbconvert/templates/latex/index.tex.j2
