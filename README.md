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
Python 依存の同期には `setup/uv-sync.sh` を呼び出しており、OS/アーキテクチャごとに `uv sync --python-platform ...` を切り替えて解決しています。手動で `uv sync` を実行する場合も `bash setup/uv-sync.sh` を利用すると、Mac (CPU/MPS) / Linux (CUDA) の両環境で同じコマンドを再現できます。詳細は [docs/python-platform-constraints.md](docs/python-platform-constraints.md) を参照してください。

### devcontainer のベースイメージ切り替え

`.devcontainer/.env.example` を `.devcontainer/.env` にコピーし、以下の環境変数でベースイメージを切り替えられます (Compose は `.devcontainer/compose.yml` と同じディレクトリの `.env` を自動で参照します)。

| 変数 | 例 | 説明 |
| --- | --- | --- |
| `BASE_IMAGE` | `ubuntu:24.04` (CPU) / `nvidia/cuda:13.0.2-cudnn-devel-ubuntu24.04` (GPU) | Dockerfile で利用するベースイメージ |
| `GPU_ENABLED` | `false` / `true` | `true` の場合に CUDA ベースでビルドしたことをコンテナ内に伝える (ドキュメント用途) |
| `TARGET_PLATFORM` | `linux/amd64` / `linux/arm64` | Apple Silicon で CPU 版 devcontainer を使う場合に `linux/arm64` を指定 |
| `GPU_COUNT` | `0` / `all` / `1` | Docker Compose の `device_requests` 相当。GPU を利用しない場合は 0 のまま、利用する場合は `all` などに変更 |
| `GPU_DRIVER` | `nvidia` | 特殊なドライバが必要なケースで上書き |

GPU を利用するビルド例 (WSL2 + NVIDIA):

```bash
cd .devcontainer
cp .env.example .env
echo "BASE_IMAGE=nvidia/cuda:13.0.2-cudnn-devel-ubuntu24.04" >> .env
echo "GPU_ENABLED=true" >> .env
echo "GPU_COUNT=all" >> .env
echo "TARGET_PLATFORM=linux/amd64" >> .env
```

Apple Silicon など CPU/MPS で利用する場合は `.env` を作成せずに `BASE_IMAGE=ubuntu:24.04` のデフォルトを利用するか、以下のように `TARGET_PLATFORM=linux/arm64` を設定してください。

```bash
cd .devcontainer
cp .env.example .env
echo "TARGET_PLATFORM=linux/arm64" >> .env
```

## 起動

VSCodeのJupyterの拡張機能での利用が可能な他、ブラウザで利用する場合は以下の手順に従ってください。

[start-lab.sh](start-lab.sh) を実行し、ターミナルに表示される、以下のようなURLをブラウザに貼り付けて遷移してください。(トークン部分は実行ごとに可変)

```
http://127.0.0.1:8888/tree?token=d7a1adaabd11cc136262b0e121eea810d1699b0d8cbae5bf
```

Github Copilot 等の拡張機能を利用する場合は VSCode の Jupyter の拡張機能での利用を推奨します。
