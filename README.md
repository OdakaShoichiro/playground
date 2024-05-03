# Playground

分析系のコードの実行環境をまとめたdevcontainerです。  
様々な言語を`Jupyter Lab`で実行できます。

## 動作環境

NVIDIA製のGPUを搭載したWindows端末上で、WSL2をバックエンドにした`Docker Desktop`を利用する前提で環境構築しています。  
（GPUを利用しない場合、[Dockerfile](.devcontainer/Dockerfile)や[compose.yml](.devcontainer/compose.yml)に若干の修正が必要になります。）

実行するWSL2には以下のライブラリをインストールしてください。

* `nvidia-container-toolkit`
* `nvidia-docker2`

また、NVIDIA公式の案内に従い、`CUDA Support for WSL 2`をインストールしてください。
https://docs.nvidia.com/cuda/wsl-user-guide/index.html

## 初期セットアップ

各言語について、初期セットアップを行ってください。

[setup-all.sh](setup/setup-all.sh) あるいはその中の各言語のセットアップコマンド・スクリプトを実行することでセットアップできます。
各言語のランタイムは[mise](https://mise.jdx.dev/)で管理されています。

なお、CaboChaについては以下の注意点があります。

* ファイルサイズの大きいものについて、Googleドライブからスクリプトで取得できず、手動で取得したファイルをworkspaceに配置してワークアラウンドするスクリプトとなっています。
* Python3.12以降では組み込みのimpモジュールが削除されるため、インストールスクリプトを手動で修正し差し替える必要があります。

## 起動

[start-lab.sh](start-lab.sh) を実行し、ターミナルに表示される、以下のようなURLをブラウザに貼り付けて遷移してください。(トークン部分は実行ごとに可変)

```
http://127.0.0.1:8888/tree?token=d7a1adaabd11cc136262b0e121eea810d1699b0d8cbae5bf
```

VSCode の Jupyter の拡張機能でもある程度の利用は可能です。
