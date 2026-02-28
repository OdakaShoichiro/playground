# Mac サポートマトリクス / Docker Desktop 設定

Issue #5 (mac-hw-matrix) の成果物ドラフト。

## サポート対象

| 項目 | Apple Silicon (推奨) | Intel Mac (最小) |
| --- | --- | --- |
| CPU | M1 / M2 / M3 (4+ Performance core 推奨) | Intel Core i7 6th Gen 以上 |
| RAM | 16GB 以上 (32GB 推奨) | 16GB 以上 |
| ストレージ | 100GB 以上の空き (Docker image + devcontainer) | 100GB 以上 (WSL と同程度) |
| macOS | Sonoma 14.x 以上 (14.5 で検証) | Ventura 13.6 以上 |
| Docker Desktop | 4.30+ (Rosetta サポート, VirtioFS 対応) | 4.30+ |

### 備考
- Apple Silicon で `linux/arm64` devcontainer を前提にする。`Rosetta for Linux` / `Use Rosetta for x86/amd64 emulation on Apple Silicon` は GPU モードを使わない限り不要。
- Intel Mac は `linux/amd64` の CPU モードのみをサポート。CUDA を利用したい場合は外付け eGPU + 対応ドライバが必要だが、動作保証外。

## Docker Desktop 推奨設定

| 項目 | 推奨値 | 理由 |
| --- | --- | --- |
| Resources > CPUs | 6 以上 | `torch` 等で並列ビルド/実行を行うため |
| Resources > Memory | 12GB 以上 (16GB 推奨) | `uv sync`, `JupyterLab` など複数ランタイムを同時利用 |
| Resources > Swap | 1-2GB | メモリ不足時の fallback |
| Resources > Disk image size | 80GB 以上 | Docker イメージ + devcontainer 層で ~40GB, 余裕を持たせる |
| General > Use Rosetta for x86/amd64 emulation | 必要に応じて | Apple Silicon で x86 バイナリが必要な場合のみ |
| Settings > Virtualization Framework | `Use virtualization framework` + `VirtioFS` 有効 | ファイルシステム性能向上 |

## セットアップチェックリスト

1. Docker Desktop をインストールし、上記設定を適用 (CPU/RAM/ディスク)。
2. Apple Silicon の場合: `brew install --cask docker`, `Rosetta` は必要に応じて `softwareupdate --install-rosetta`。
3. `.devcontainer/.env` をコピーし、`TARGET_PLATFORM=linux/arm64` (Apple) or `linux/amd64` (Intel) を設定。
4. GPU を利用しない場合は `BASE_IMAGE=ubuntu:24.04`, `GPU_COUNT=0` のまま利用。
5. Python 依存は `bash setup/uv-sync.sh` で同期し、`torch.backends.mps.is_available()` で MPS backend を確認。

## FAQ / 既知の制限

| 質問 | 回答 |
| --- | --- |
| **Q1. Apple Silicon で CUDA を使えますか?** | いいえ。Metal/MPS のみサポート。GPU ワークロードは Linux + NVIDIA GPU マシンを利用してください。 |
| **Q2. Intel Mac で GPU モードを使う方法は?** | サポート外。CUDA 対応 eGPU + Docker Desktop + NVIDIA ドライバを整える必要があり、動作保証できません。 |
| **Q3. Docker Desktop が重く、ファイル I/O が遅い** | VirtioFS が有効か確認し、`Use gRPC FUSE` を無効化。`~/Library/Containers/com.docker.docker/Data/vms/0` のストレージ確保。 |
| **Q4. `uv sync` が wheel を解決できない** | Apple Silicon では `setup/uv-sync.sh` を使用し、`UV_TORCH_BACKEND=cpu` で実行。`pyproject` のマーカーが `arm64/aarch64` を含むことを確認。 |
| **Q5. MPS backend が利用できない** | macOS 14 以上、Xcode Command Line Tools を最新にし、`pip install torch` (arm64) を実行後に `PYTORCH_ENABLE_MPS_FALLBACK=1` を設定。 |
| **Q6. ストレージ不足で devcontainer がビルドできない** | Docker Desktop の `Disk image size` を 100GB 以上に拡張し、不要なコンテナ/イメージを削除 (`docker system prune`). |

## 次のアクション
- README or Wiki にこの表を転載し、ユーザー onboarding 手順に組み込む。
- Ops チームと実機検証を行い、最小構成でも devcontainer 起動・Jupyter 起動が可能か確認。
