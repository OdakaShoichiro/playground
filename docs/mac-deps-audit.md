# Issue #2 mac-deps-audit

Milestone 0 で要求されている「GPU 依存パッケージの棚卸し」に対応したメモです。  
対象は devcontainer のセットアップで導入される Python (uv), R (renv), Julia, Bun/Node それぞれの依存です。

## サマリー
- GPU 前提の強い依存は Python の深層学習系 (`torch`, `tensorflow`, `jax/jaxlib`) と、それらに付随して `uv.lock` に解決済みの NVIDIA CUDA 12.x ランタイム (`nvidia-cublas-cu12` など) および `triton` に集中している。
- R (`renv.lock` + `setup-renv.R`), Julia (`Project.toml`/`Manifest.toml`), Bun (`package.json`) には CUDA/Metal など GPU 固有バイナリの依存はない。`xgboost` など一部ライブラリは GPU 加速をサポートするが、ビルド時に明示的に有効化しない限り CPU モードで動作する。
- `notebook/` 配下は `.gitkeep` のみで GPU 必須ノートブックは未登録。README の手順以外に GPU を前提にしたスクリプトは確認できなかった。

## Python (uv / `pyproject.toml`, `uv.lock`)

| カテゴリ | パッケージ | GPU 依存/課題 | Mac での代替案・メモ |
| --- | --- | --- | --- |
| Deep Learning | `torch==2.9.1` (`pyproject.toml`, `uv.lock`), 付随して `nvidia-cublas/cuDNN/cuFFT/cuSPARSE/cuRAND/nvjitlink/nvtx`, `triton` | `uv.lock` では Linux x86_64 + CUDA 12.8 の manylinux wheel を固定。`nvidia-*` と `triton` は `platform_machine == 'x86_64' and sys_platform == 'linux'` 条件付きで、Mac ではビルド対象外だが CUDA ランタイムが無いと GPU コードは実行不可。 | Intel/Apple Mac では `pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu` (CPU) か、Apple Silicon の場合は公式 wheel + MPS backend を使用。MPS 有効化には `PYTORCH_ENABLE_MPS_FALLBACK=1` を推奨。`torch.cuda` を直接呼ぶコードには CPU/MPS fallback を追加する必要あり。 |
| Deep Learning | `tensorflow==2.20.0` | Linux/Windows では CUDA 12 を要求し、`uv.lock` の wheel も GPU 対応ビルド。Apple Silicon 向けに `macosx_12_0_arm64` wheel は存在するが、Metal GPU を使うには `tensorflow-macos` + `tensorflow-metal` を利用するのが一般的。 | Intel Mac: CPU 版 `tensorflow` をそのまま利用。Apple Silicon: `pip install tensorflow-macos tensorflow-metal` への切り替えと `arm64` wheel の固定が必要。 |
| Deep Learning | `jax>=0.8.2` + `jaxlib` | `jaxlib` の解決済み wheel には macOS arm64 版も含まれるが GPU はサポート外。Linux x86_64/ARM では CPU/TPU ビルドで GPU サポートには CUDA 対応 extra (`jax[cuda12_pip]`) が必要。 | Apple Silicon: `pip install "jax[cpu]" jaxlib` + `jax-metal`で Metal backend、もしくは CPU のみ。Intel Mac: CPU ビルド。 |
| GBDT | `lightgbm>=4.6.0` | GPU (OpenCL/CUDA) でビルド可能だが、`pip` 車輪は CPU。Mac で GPU を有効化するにはソースビルドと OpenCL/CUDA toolchain が必要で現状非対応。 | CPU モードで動作、Mac 対応は不要。ただし Apple Silicon では `brew install libomp` など依存を追加しないとビルドでエラーになる可能性あり。 |
| Probabilistic | `pymc`, `pytensor` | `pymc` は `jax`/`aesara` を backend にでき、GPU 加速は `jax` 側の対応に依存。 | `jax` の方針に追従し、CPU or MPS での動作を確認。 |
| Misc. | `tensorflow-io-gcs-filesystem` 等の TF 連携パッケージなし → 影響なし | - | - |

### 追加で把握した制限
- `uv.lock` に含まれる `nvidia-*` 系 12 パッケージ (`nvidia-cublas-cu12`, `nvidia-cudnn-cu12`, `nvidia-cusolver-cu12`, `nvidia-cusparse-cu12`, `nvidia-cufft-cu12`, `nvidia-curand-cu12`, `nvidia-cusparselt-cu12`, `nvidia-cuda-runtime-cu12`, `nvidia-cuda-nvrtc-cu12`, `nvidia-cuda-cupti-cu12`, `nvidia-nccl-cu12`, `nvidia-nvjitlink-cu12`, `nvidia-nvshmem-cu12`, `nvidia-nvtx-cu12`, `nvidia-cufile-cu12`) はすべて `platform_machine == 'x86_64' and sys_platform == 'linux'` 条件で解決されている。Mac では無視されるものの、GPU 対応を想定したコードパス (`torch.cuda.*`) は CUDA 前提のまま。
- `triton==3.5.1` も linux/x86_64 wheel のみ。Mac では import できず `torch` の一部機能 (Inductor) が制限されるため、条件付き依存への変更が必要。

## R (`renv.lock`, `setup-renv.R`)
- `setup-renv.R` で追加インストールしているパッケージのうち、GPU 依存があるのは `xgboost` のみ。ただし CRAN バイナリは CPU ビルドで、GPU を利用するには CUDA/OpenCL を有効にしたソースビルドが必要なため、Mac 上では CPU モードで問題なく動作する (GPU がなくてもエラーにならない)。
- `reticulate`, `Rcpp`, `rstan` 等は GPU を直接要求しない。`rstan` は C++ toolchain のみ依存。
- `RMeCab` や `fastSOM` などは CPU のみ。

## Julia (`Project.toml`, `Manifest.toml`)
- 依存は `DataFrames`, `Plots`, `IJulia` のみで GPU パッケージは存在しない。
- Mac 対応で追加作業は不要。

## Bun / Node (`package.json`)
- `@marp-team/marp-cli` と `cspell` 系辞書のみ。GPU 依存はなし。

## ノートブック / サンプル
- `notebook/` 以下は `.gitkeep` のみで、GPU をハードに要求するノートブックは現状登録なし。
- 既存コードベース (`src/`) にも `torch.cuda` など直接 CUDA を叩く記述は確認できなかった (`rg -n \"cuda\"` で README と `uv.lock` 以外ヒットなし)。

## 次アクション案
1. Python 依存の中で GPU が必須のもの (`torch`, `tensorflow`, `jax`) は CPU/MPS で利用するための extra 要件・インストールコマンドを `setup/setup-all.sh` から切り替え可能にする (Milestone 1 の入力)。
2. `nvidia-*`/`triton` を Mac では解決しないよう `platform` 条件を pyproject あるいは uv constraints に明示する (CI で `uv sync` が Mac でも通るか検証)。
3. `torch.cuda` 依存コードが今後追加される場合に備え、テンプレートノートブックに CPU/MPS fallback の記述を追加する。
