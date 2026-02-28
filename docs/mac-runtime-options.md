# Issue #3 mac-runtime-options

Milestone 0 で Mac (Intel / Apple Silicon) でも Playground を動作させるために、主要な ML ランタイムの CPU/MPS 版インストール手順と fallback 戦略を整理したメモ。

## 対象と前提
- Python 依存 (`pyproject.toml`) のうち GPU 依存度が高いライブラリ: `torch`, `tensorflow`, `jax`, `lightgbm`, `xgboost`, `pymc`。
- 想定プラットフォーム
  1. Windows/Linux + NVIDIA GPU (既存: CUDA 12.x)
  2. Linux (amd64/arm64) + CPU のみ
  3. macOS Intel + CPU のみ
  4. macOS Apple Silicon + Metal Performance Shader (MPS)
- `setup/setup-all.sh` から `GPU_ENABLED` や `APPLE_SILICON` 等のフラグを受け取り、pip コマンドを切り替える方針 (Milestone 1 #7)。

## PyTorch

| 環境 | 推奨インストールコマンド | メモ |
| --- | --- | --- |
| NVIDIA GPU (Linux/WSL) | `pip install torch==2.9.1 torchvision==0.20.1 torchaudio==2.9.1 --index-url https://download.pytorch.org/whl/cu124` | `uv.lock` が参照する CUDA 12.4 wheel 相当。`nvidia-*` および `triton` を合わせて解決する。 |
| CPU のみ (Linux/Intel Mac) | `pip install torch==2.9.1 torchvision==0.20.1 torchaudio==2.9.1 --index-url https://download.pytorch.org/whl/cpu` | `torch.cuda` は False になるため、コード側で `torch.device('cpu')` fallback を必須にする。 |
| Apple Silicon (MPS) | `pip install torch==2.9.1 torchvision==0.20.1 torchaudio==2.9.1` (PyPI arm64 wheel) + `export PYTORCH_ENABLE_MPS_FALLBACK=1` | 公式 arm64 wheel に MPS backend が含まれている。未対応オペレーションは自動的に CPU fallback。`torch.backends.mps.is_available()` で確認。 |

### PyTorch Fallback ガイド
```python
import torch

if torch.cuda.is_available():
    device = torch.device("cuda")
elif torch.backends.mps.is_available():
    device = torch.device("mps")
else:
    device = torch.device("cpu")
```
このコード片をテンプレートノートブックに含め、`device` を明示する。

## TensorFlow

| 環境 | 推奨インストールコマンド | メモ |
| --- | --- | --- |
| NVIDIA GPU (Linux/WSL) | `pip install tensorflow==2.20.0` + CUDA 12.x ドライバ | `uv.lock` では GPU wheel を参照。`TF_FORCE_GPU_ALLOW_GROWTH=true` 推奨。 |
| CPU (Linux/Intel Mac) | `pip install tensorflow==2.20.0` | GPU 関連パッケージは不要。 |
| Apple Silicon (MPS) | `pip install tensorflow-macos==2.20.0 tensorflow-metal==1.2.0` | `tensorflow-macos` が CPU/MPS を含み、`tensorflow-metal` で Metal backend を提供。`export TF_ENABLE_ONEDNN_OPTS=0` で一部演算の互換性向上。 |

TensorFlow では `tf.config.list_physical_devices()` で `GPU` (MPS) の検出を行い、未検出の場合も CPU にフォールバックするコードを推奨。

## JAX

| 環境 | 推奨インストールコマンド | メモ |
| --- | --- | --- |
| NVIDIA GPU (Linux) | `pip install "jax[cuda12_pip]" jaxlib==0.8.2 -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html` | CUDA 12 対応の wheels を指定。 |
| CPU (Linux/Intel Mac) | `pip install "jax[cpu]" jaxlib==0.8.2` | CPU のみ。`OMP_NUM_THREADS` で並列数を調整。 |
| Apple Silicon (Metal) | `pip install jax-metal==0.0.7 jaxlib==0.8.2` | `jax-metal` が Metal backend。`jax` 本体は `pip install jax==0.8.2`。 |

`jax.devices()` で `GPU` や `TPU` が返らない場合は CPU 実行になることをドキュメント化する。

## LightGBM / XGBoost
- `lightgbm==4.6.0`: pip wheel は CPU ビルド。GPU (OpenCL/CUDA) を使う場合はソースビルドが必要で、Mac では OpenCL ドライバが標準提供されないため CPU 前提とする。
- `xgboost` (R/Python 双方): pip/CRAN wheel は CPU 版。Mac で GPU を有効化するには CUDA/OpenCL toolchain を追加する必要がありサポート外とする。

## PyMC / PyTensor
- `pymc` は backend に `jax` を利用するため、上記 JAX の手順に従う。Metal backend を使う場合は `PYMC_JAX_FALLBACK=1` (任意の env) を推奨し、`jax` が CPU/VML へ fallback した場合でも処理が継続するよう documented fallback を用意する。

## ドキュメント/実装タスクへの入力
1. `setup/setup-all.sh` および README に上記コマンド/環境変数を追記 (Issue #7)。
2. `pyproject.toml` / `uv.lock` で CUDA wheel を Linux x86_64 のみに制限し、Mac 用 wheel を別セクションに記述 (Issue #8)。現状は `setup/uv-sync.sh` で `uv sync --python-platform` を切り替えている。
3. notebook テンプレートで PyTorch/TensorFlow/JAX の fallback コードの使用を徹底 (Issue #9)。
