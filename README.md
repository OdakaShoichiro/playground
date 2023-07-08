# Playground

分析系のコードの実行環境をまとめたdevcontainerです。  
様々な言語をJupyter Notebookで実行できます。

## 動作環境

NVIDIA製のGPUを搭載したWindows端末上で、WSL2をバックエンドにした`Docker Desktop`を利用する前提で環境構築しています。  
（GPUを利用しない場合、[Dockerfile](.devcontainer/Dockerfile)や[compose.yml](.devcontainer/compose.yml)に若干の修正が必要になります。）

実行するWSL2には以下のライブラリをインストールしてください。

* `nvidia-container-toolkit`
* `nvidia-docker2`

また、NVIDIA公式の案内に従い、`CUDA Support for WSL 2`をインストールしてください。
https://docs.nvidia.com/cuda/wsl-user-guide/index.html

## Startup

Python・Rについては、初期セットアップを行ってください。

```shell
# Python
rye sync

# R
Rscript setup-renv.R 
```
