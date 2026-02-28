# Mac対応ロードマップ

## 現状認識
- `.devcontainer/Dockerfile` は `nvidia/cuda:13.0.2-cudnn-devel-ubuntu24.04` をベースにしており、CUDA 前提で apt パッケージや MeCab 拡張辞書を導入している。
- README でも WSL2 + NVIDIA GPU を必須としており、Mac (特に Apple Silicon) では Docker イメージがそのままでは動作しない。
- GPU 依存パッケージ (PyTorch, JAX, TensorFlow など) の `requirements` は CPU 版と分離管理されていないため、環境構築スクリプトの分岐がない。

## Milestone 0: 調査と要件定義 (1 週間)
1. 依存関係棚卸し: `pip/conda`, `R`, `Julia`, `Rust` などのランタイムが GPU 機能に依存している箇所を一覧化。
2. 代替手段の評価: Mac 上で CPU のみで十分か、あるいは `metal` / `mps` を使うべきライブラリ (PyTorch, TensorFlow-macos 等) を選定。
3. ベースイメージ戦略: `nvidia/cuda` とは別に `ubuntu:24.04` ベースの CPU イメージ、もしくは multi-arch build を採用する方針を決定。
4. 開発用マシンの定義: Intel Mac / Apple Silicon でサポートする最低バージョン、必要な Docker Desktop 設定 (Rosetta, VirtioFS など) を確定。

### Milestone 0 の Issue 化
| Issue (ドラフト) | 主要作業 | 成果物 | Owner | 期限 |
| --- | --- | --- | --- | --- |
| `#1 mac-deps-audit` | `pip`, `R`, `Julia`, `Rust`, `Node/Bun` の GPU 依存パッケージ調査、現状のセットアップスクリプト確認 | 言語別依存関係シート、GPU/CPU 分岐が必要な箇所の一覧 | Platform (odakashoichiro) | 起票日+3d |
| `#2 mac-runtime-options` | PyTorch/JAX/TensorFlow などの CPU/MPS 版の可用性を調査し、優先度と推奨バージョンを決定 | 代替ライブラリ・インストール方法の提案ドキュメント | ML (assistant) | 起票日+4d |
| `#3 base-image-strategy` | CUDA ベースイメージと CPU イメージのマトリクス作成、multi-arch 対応可否の確認、Docker Desktop 設定調査 | ベースイメージ選定メモと意思決定記録 | DevInfra (tbd) | 起票日+5d |
| `#4 mac-hw-matrix` | Intel/Apple Silicon それぞれの macOS バージョン、RAM/GPU/ストレージ要件、Docker 設定 (Rosetta, VirtioFS) を整理 | サポート対象マシン表とセットアップチェックリスト | Ops (tbd) | 起票日+5d |
| `#5 milestone0-sync` | 上記 4 件のアウトプット確認、Milestone 1 への入力整理、ブロッカー洗い出し | Milestone 0 レポート、次フェーズの課題リスト | PM (tbd) | 起票日+7d |

それぞれの Issue には「成果物テンプレート (Google Sheet / Markdown)」「レビュー担当」「承認条件 (例: 2 名の確認)」を明記する。

## Milestone 1: CPU 向け devcontainer 基盤 (2 週間)
1. `.devcontainer/Dockerfile` を `ARG GPU_ENABLED` などのビルド引数で分岐させ、GPU 無しの場合は `ubuntu:24.04` ベースで CUDA ランタイムを除いた構成を作成。
2. `compose.yml` と `devcontainer.json` に platform (`linux/arm64` / `linux/amd64`) の選択肢と、Apple Silicon での volume マウント最適化を追加。
3. Setup スクリプト (`setup/setup-all.sh` 等) を GPU/CPU で切り替え可能にし、PyTorch などのインストールコマンドを `pip install torch==...+cpu` のように条件分岐。
4. README に Mac 固有の手順 (Homebrew での `mise` インストール、Docker Desktop 設定、start-lab.sh の前提) を追記。
5. 手元の Intel Mac / Apple Silicon で CPU バージョンの devcontainer がビルド・起動できることを確認。

## Milestone 2: Apple GPU/MPS 対応 (2〜3 週間)
1. PyTorch, TensorFlow, JAX などで Metal Backend を使用できるバージョンを検証し、`requirements`/`pyproject` にオプションとして定義。
2. Apple の `tensorflow-macos`, `tensorflow-metal`, `torch==...` (mps) 系の wheel をインストールするための追加リポジトリ設定や `arch` 判定ロジックをスクリプト化。
3. JupyterLab で GPU (MPS) を利用する簡易ノートブックを作成し、CI or 手動で再現性を確認。
4. 既存の CUDA コード (例: `torch.cuda.is_available()` 依存) を条件付きに書き換え、MPS or CPU fallback を持たせる。

## Milestone 3: 自動化とテスト (1〜2 週間)
1. GitHub Actions などで `linux/amd64` + CUDA, `linux/arm64` + CPU の 2 パターンでビルド/セットアップテストを行うワークフローを追加。
2. `start-lab.sh` や各言語セットアップに対して基本的なヘルスチェック (Jupyter 起動, `pip list`, `julia --project -e 'using Pkg; Pkg.test()'` など) を Mac 上で自動実行。
3. issue / PR テンプレートで「Mac 対応部分に影響する変更」チェックボックスを追加し、回 regressions を防止。

## Milestone 4: ドキュメントとナレッジ整備 (並行作業)
1. README, `roadmap.md`, Wiki に Mac 前提で必要なハードウェア/ソフトウェア要件、既知の制限事項を明記。
2. トラブルシューティング (Rosetta が必要なケース、Docker のリソース配分、Metal backend の制約) をまとめた FAQ を作成。
3. Windows/Mac 双方の手順を CI で定期検証し、破綻した場合は早期に検知できる体制を整える。

## リスクとフォローアップ
- Apple Silicon は `linux/arm64` イメージで動作するが、x86 専用バイナリや wheel が存在する場合はビルドが失敗する可能性があるため、代替パッケージやソースビルドの可否を確認する。
- GPU 前提のノートブックは性能差が顕著なため、CPU/MPS での推奨実行時間や設定を記載する。
- CUDA 専用の最適化コードを無効化する切替フラグを用意し、今後のアップデートで分岐漏れが発生しないようにする。
