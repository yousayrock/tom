# Dev Team V3.1 (Phase 1)

`docs/DEV_TEAM_V3_SPEC.md` の Phase 1 実装: Goose Orchestrator、Dynamic Routing、
Feature / Bugfix / Refactor / Brainstorm の各 Recipe。

goose の recipe / sub_recipes 機構をそのまま利用しており、Rustコードの変更は不要です。

## 使い方

```bash
tom run --recipe workflow_recipes/dev_team_v3/orchestrator.yaml \
  --params task="ログイン画面にパスワード再設定機能を追加したい"
```

Orchestrator がタスクを分類し、`recipes/feature.yaml` などの Recipe を選び、
規模に応じて `roles/` 配下の担当（Researcher / Architect / Implementer / Tester /
Quality Reviewer / Security Reviewer / Final Reviewer）を必要な分だけ呼び出します。

個別の Recipe を直接呼ぶこともできます。

```bash
tom run --recipe workflow_recipes/dev_team_v3/recipes/bugfix.yaml \
  --params task="ログイン後にセッションが切れる不具合を直したい"
```

## モデルの割り当て

`DEV_TEAM_V3_SPEC.md` #4 にある Role→Model の推奨割り当ては、現時点ではモデル名を
過度に固定しないため各 `roles/*.yaml` にコメントアウトで残しています。実際に使う
provider/model が決まったら、該当ファイルの `settings.goose_model` /
`settings.goose_provider` のコメントを外して設定してください。未設定の場合は
`goose configure` で設定した既定モデルがそのまま使われます。

## NVIDIA補助担当とタイムアウト

`recipes/brainstorm.yaml` は `roles/brainstorm_perspective_nvidia.yaml` を補助的に
呼び出しますが、NVIDIA無料Hosted Endpointは混雑・rate limit・応答遅延があり得るため、
これをクリティカルパスに置かない設計にしています（`DEV_TEAM_V3_SPEC.md` #5）。

- `brainstorm_perspective_nvidia.yaml` は `extensions.timeout: 90`（秒）と短めに設定
- instructions でリトライ上限（最大2回）とSkip条件を明記
- 失敗・タイムアウト時は GPT/Claude側（`brainstorm_perspective`）の結果だけで
  Phase 2 以降に進む
- Feature/Bugfix/Refactor の各 Recipe（Standard/High Risk routing）では現状NVIDIA担当を
  呼んでいない。Phase 3 で Fast Agent / Coding Agent 等をクリティカルパス外の補助として
  追加する際も、同様に短いタイムアウトとSkipロジックを必須にすること。

## 未実装（Phase 2 以降）

- Human Gate の自動停止・失敗回数カウントの仕組み化（現状は instructions 内の指示のみ）
- NVIDIA Hosted API の実測ベンチマーク・成功率に基づくモデル入れ替え（`DEV_TEAM_V3_SPEC.md` #6）
- Model Routing の自動化・成功率記録（`DEV_TEAM_V3_SPEC.md` #10, Phase 3-4）
- Dependency Reviewer / Documentation / Release / DevOps 担当

詳細は `docs/DEV_TEAM_V3_SPEC.md` の「17. 初期実装優先順位」を参照。
