# Issue #4 base-image-strategy

## 現状
- `.devcontainer/Dockerfile` は `FROM nvidia/cuda:13.0.2-cudnn-devel-ubuntu24.04` 固定で、CUDA 前提のライブラリ (`nvidia-container-toolkit`, CUDA Runtime) を前提にしている。
- `compose.yml` では `deploy.resources.reservations.devices` で NVIDIA GPU を要求し、WSL2 + Docker Desktop + NVIDIA ドライバがないと devcontainer が起動しない。
- Apple Silicon / Intel Mac では CUDA を利用できないため、CPU (もしくは Metal/MPS) 前提の base image が別途必要。

## 目的
1. GPU (CUDA) 環境と CPU/MPS 環境で devcontainer をビルド・起動できるようにする。
2. Docker buildx で `linux/amd64` / `linux/arm64` の multi-arch ビルドに対応し、Apple Silicon でも再現可能にする。
3. 開発者が `GPU_ENABLED` (仮称) や `TARGET_PLATFORM` の設定のみで適切なイメージを選択できるようにする。

## 提案する構成

### Dockerfile レイヤー構成
| セクション | CUDA (GPU) モード | CPU/MPS モード | 備考 |
| --- | --- | --- | --- |
| ベースイメージ | `nvidia/cuda:13.0.2-cudnn-devel-ubuntu24.04` | `ubuntu:24.04` | `ARG GPU_ENABLED=true` を導入し、`FROM ${GPU_ENABLED:+nvidia/...}` のように切り替え。 |
| NVIDIA ツール | 既存のまま (`nvidia-*` ランタイムが含まれる) | スキップ | CPU モードでは `apt` で `nvidia-*` をインストールしない。 |
| 共通依存 | clang/cmake/git/mecab など | 同じ | 可能な限り共通レイヤーにまとめる。 |
| GPU 専用 | `nvidia-container-toolkit` の設定、`CUDA` 用の env | スキップ | GPU のみ `ENV NVIDIA_VISIBLE_DEVICES=all` 等を設定。 |

### build arguments / compose オプション
- `ARG GPU_ENABLED=true`: Dockerfile で base image と GPU 専用レイヤーの導通に使用。
- `ARG TARGETARCH`, `ARG TARGETPLATFORM`: buildx から渡される値を利用し、Apple Silicon (`linux/arm64`) と Windows/Linux (`linux/amd64`) の差分を吸収。
- `docker-compose` 側では以下を追加/調整:
  - `platform: ${TARGET_PLATFORM:-linux/amd64}` (Apple Silicon で `linux/arm64` に切り替え)
  - GPU モード時のみ `deploy.resources.reservations.devices` を有効化 (compose override か env 条件で制御)。

### ビルド・配布の流れ
1. `devcontainer.json` で `"runArgs"` もしくは `compose` override を使い、`GPU_ENABLED` と `TARGET_PLATFORM` を `build.args` に注入。
2. `Makefile` or ドキュメントでビルド例を用意:
   ```bash
   docker buildx build \
     --build-arg GPU_ENABLED=true \
     --platform linux/amd64 \
     -t playground:cuda .

   docker buildx build \
     --build-arg GPU_ENABLED=false \
     --platform linux/arm64 \
     -t playground:cpu .
   ```
3. Apple Silicon 利用者は `GPU_ENABLED=false` + `platform=linux/arm64` をデフォルトとし、Metal/MPS はコンテナ内で Python ランタイムが担う。

## 実装タスクリスト (Milestone 1 でやること)
1. `.devcontainer/Dockerfile` を 2-staged にリファクタリングし、`ARG GPU_ENABLED` による base image 分岐と GPU レイヤーの条件分岐を実装。
2. `.devcontainer/compose.yml` に `platform` を追加し、`GPU_ENABLED` が false の場合は `deploy.resources.reservations.devices` セクションを無効化できるよう `profiles` or override ファイルを導入。
3. `devcontainer.json` から `runArgs` or `build` セクションで `GPU_ENABLED`/`TARGET_PLATFORM` を指定できるようにする（ユーザー設定で上書き可能にする）。
4. README / docs に CUDA モードと CPU/MPS モードのビルド・起動方法を追記。
5. GitHub Actions などで `docker buildx build` (GPUモードは manifest の lint のみ or CI skip) を実行し、arm64 build が成功するかを検証。

## リスク・検討事項
- NVIDIA CUDA ベースのイメージを Apple Silicon でビルドする場合、qemu emulation で時間がかかる。実際には GPU モードは Linux/x86_64 環境でのみビルドし、Apple Silicon は CPU モードを利用する運用が現実的。
- `nvidia-container-toolkit` はホスト側依存のため、CPU モードで余計な設定を残さないよう Dockerfile/compose から条件付きで削除する必要がある。
- CUDA 版と CPU 版の `apt` レイヤーを共通化しすぎるとキャッシュが効きにくくなるので、`FROM` の後に共通 `ARG` を配置し layer を揃える。
