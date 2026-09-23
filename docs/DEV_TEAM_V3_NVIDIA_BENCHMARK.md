# Dev Team V3.1 NVIDIA 実測ベンチマーク

`DEV_TEAM_V3_SPEC.md` #6「NVIDIAモデル実測ベンチマーク」に基づく実測記録。

- 実施日: 2026-09-23（JST）
- 環境: トム(goose 1.48.0) + `active_provider: nvidia`（`~/.config/goose/config.yaml`）
- 方法: `goose run --provider nvidia --model <model> --text "1+1は?数字だけ答えて" --no-session`
  を各モデルに対して実行し、Total Response Time（完了までの時間）とタイムアウト有無を記録
- 単純な1問だけの計測であり、実タスク（Agentic coding、長い文脈）での挙動は別途要検証

## 結果

| Spec上の枠 | 実際のモデルID | 試行 | 結果 | 評価 |
|---|---|---|---|---|
| Fast Agent（高速補助担当） | `nvidia/nemotron-3.5-lightning-30b-a3b` | 5回 | 成功3回（24〜33秒）、60秒タイムアウト2回 | △ やや不安定。timeout 100秒程度＋リトライ推奨 |
| Coding Agent（コード補助担当） | `poolside/laguna-xs-2.1` | 1回 | 成功（約67秒） | △ 遅い。timeout 110秒程度が必要 |
| Reasoning / Final Review（推論・最終確認担当） | `nvidia/nemotron-3-super-120b-a12b` | 1回 | 成功（約3.4秒） | ◎ 高速・安定 |
| Brainstorm（発想担当） | `moonshotai/kimi-k3` | 2回 | 失敗（120秒・200秒双方でタイムアウト。1回はプロセス全体が588秒経過しても未完） | ✕ 実用不可レベル。既定では使わない |
| Brainstorm（発想担当・代替） | `z-ai/glm-5.3` | 1回 | 成功（約119秒、120秒キャップぎりぎり） | △ 遅く不安定。使うならtimeout 180秒以上＋リトライ必須 |
| Deep Reasoner（難問検証担当） | `nvidia/nemotron-3-ultra-550b-a55b` | 1回 | 成功（約3.9秒） | ◎ 高速・安定（単純な質問のため、実際の難問では要再検証） |

## この結果からの変更

- `workflow_recipes/dev_team_v3/roles/brainstorm_perspective_nvidia.yaml` の既定モデルを、
  プレースホルダから実測で高速・安定だった `nvidia/nemotron-3-super-120b-a12b` に変更し、
  `extensions.timeout` を 60秒に設定した。
- Kimi系・GLM系は現時点の実測では遅すぎる／不安定なため、既定候補から外した。
  多様な視点がどうしても必要な場合のみ、timeout・リトライ回数を十分に増やした上で
  明示的に切り替えること（本番投入前に再ベンチマーク推奨）。
- Coding Agent（Laguna XS 2.1）・Fast Agent（Nemotron Lightning）はPhase 1のRecipeでは
  まだ使用していない（Phase 3でImplementer/Tester等の補助として追加検討）。追加する際は
  上表のtimeout目安を初期値にすること。

## 未検証・今後の課題

- サンプル数が少ない（多くが1〜5回）ため、429発生率・成功率は統計的に信頼できる値ではない。
  Phase 3で継続的にログを取り、実測値を更新すること。
- 実際のAgenticタスク（コード生成・ツール呼び出し）での応答時間・Tool利用成功率は未計測。
  単純な一問一答の結果をそのままクリティカルパスの判断に使わないこと。
