# Python 依存のプラットフォーム制約

Issue #8 (`python-deps-platform-constraints`) の作業メモです。Mac 向けの CPU/MPS 環境と Linux + CUDA 環境の双方で `uv sync` を安定させるため、セットアップスクリプトと手順を更新しました。

## 変更点
1. `setup/uv-sync.sh` を追加し、`setup/setup-all.sh` から呼び出すようにした。  
   - `uname` から OS/アーキテクチャを判定し、`uv sync --python-platform <platform>` を自動付与。  
   - macOS では `UV_TORCH_BACKEND=cpu` を標準でセットし、`torch` 解決時に CUDA wheel を引きに行かないようにする。  
   - Linux x86_64 では `x86_64-unknown-linux-gnu`、Apple Silicon では `aarch64-apple-darwin` を強制することで、`uv.lock` に含まれるプラットフォームマーカーと整合させている。
2. `docs/mac-runtime-options.md` / 本ドキュメントに、`uv sync` の動作と環境変数について説明を追記。

## 利用手順
- `setup/setup-all.sh` を実行すれば OS ごとに適切な `uv sync` オプションが付与される。  
  - 追加で GPU (CUDA) wheel を明示したい場合は `UV_TORCH_BACKEND=cu124 bash setup/uv-sync.sh` のように呼び出す。  
  - Apple Silicon で Metal backend を試す場合は、`UV_TORCH_BACKEND=cpu` のままでも `torch.backends.mps` が利用可能。
- 直接 `uv sync` を叩く場合も、同じロジックを用いたいときは `setup/uv-sync.sh` を経由する。

## 今後の TODO
- `uv.lock` / `pyproject.toml` を再ロックして `torch`, `tensorflow`, `jax` の macOS arm64 wheel 情報が最新になるよう CI に組み込む。
- `UV_TORCH_BACKEND` 以外に `UV_PYTHON_PLATFORM` や `UV_INDEX` を調整する必要が出た場合は、本スクリプトを拡張する。
