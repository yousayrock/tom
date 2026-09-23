# Dev Team V3.1 仕様書・設計書

> Status: Draft / Validation Specification  
> Target: TOM  
> Version: Dev Team V3.1  
> Updated: 2026-09-23

## 1. 目的

Dev Team V3.1 は Goose を **Orchestrator（司令塔）** とし、タスクごとに必要なAI・専門担当・Skill・Recipeを動的編成する開発チーム設計である。

基本方針は「AIをたくさん呼ぶ」ことではなく、**必要なときに必要な専門家だけを呼ぶこと**。

## 2. 基本原則

- **Dynamic Team（動的チーム）**: タスクの難易度・変更範囲・リスクに応じて必要な担当だけを招集。
- **Quality Gate（品質ゲート）**: 動作しただけで完了せず、テストとレビューを通す。
- **Security Gate（セキュリティゲート）**: 認証・権限・秘密情報・外部通信等の高リスク変更を専用レビュー。
- **Human Gate（人間判断ゲート）**: 初期値3回の失敗で停止し、失敗内容・試行・仮説・必要判断をユーザーへ返す。

## 2.1 実装言語方針（Default Language Policy）

Dev Team V3.1 が新規に実装するプログラム（Implementer/Refactorer/Tester等が書くコード）は、
**特に指定がない限りRustを既定言語とする**。理由:

- **速度**: コンパイル言語であり、実行時オーバーヘッドが小さい
- **応答速度**: エージェントが作る常駐プロセス・CLI・APIサーバー等のレイテンシを抑えやすい
- **セキュリティ**: 所有権・借用チェックによりメモリ安全性がデフォルトで保証され、
  Quality Gate / Security Gate で見るべきバグの種類（メモリ破壊・未初期化アクセス等）を
  構造的に減らせる

例外は以下の場合に限り、Architect が理由を明記した上で他言語を選択してよい:

- 既存コードベースが別言語で書かれており、混在させるより一貫性を優先すべき場合
  （例: フロントエンドUI、既存Pythonスクリプト等）
- ユーザーが明示的に別言語を指定した場合
- ライブラリ・エコシステムの制約でRustでは著しく非効率になる場合

Architect はタスクの設計段階で使用言語を明記し、Rust以外を選ぶ場合は理由をセクションに含める。

## 3. Agent / Skill / Recipe / Model

- **Agent / Role（担当）** = 誰が仕事をするか
- **Skill（技能）** = どう上手に作業するか
- **Recipe（手順）** = どの順番で進めるか
- **Model（AIモデル）** = どのAIを頭脳として使うか

RoleとModelは完全固定せず、速度・品質・コスト・利用制限・成功率で切替可能にする。

## 4. V3.1 初期モデル配置

| Role（担当） | 初期モデル | 主な仕事 |
|---|---|---|
| **Orchestrator（司令塔）** | **GPT-6 Sol** | 要求理解、タスク分類、Recipe選択、担当招集、結果統合 |
| **Researcher（調査担当）** | **GPT-6 Luna** | Web/技術/API/既存コード調査、候補比較、大量情報整理 |
| **Architect（設計担当）** | **Claude Opus 最新安定版** | 要件整理、全体設計、技術選定、変更範囲、実装計画 |
| **Brainstorm Team（アイデア担当）** | **GPT + Claude + NVIDIA複数モデル** | 同じ課題を複数AIへ渡して異なる視点を発散 |
| **Implementer（実装担当）** | **GPT-6 Sol / Codex系** | コード実装、必要なテスト追加 |
| **Debugger（バグ修正担当）** | **GPT-6 Sol** | 再現、切り分け、根本原因分析、修正 |
| **Tester（テスト担当）** | **GPT-6 Luna + NVIDIA補助** | Unit/Integration/Regression/エッジケース |
| **Refactorer（コード整理担当）** | **GPT-6 Sol** | 挙動を変えず重複・複雑性を減らす |
| **Quality Reviewer（品質チェック担当）** | **Claude Sonnet 最新安定版** | 可読性、保守性、設計整合、テスト不足を確認 |
| **Security Reviewer（セキュリティ担当）** | **Claude Opus 最新安定版** | Secrets、認証・認可、入力検証、権限、依存リスク |
| **Dependency Reviewer（依存関係担当）** | **GPT-6 Luna** | バージョン、不要依存、既知問題、ライセンス |
| **Documentation（ドキュメント担当）** | **Claude Sonnet 最新安定版** | README、仕様書、設計書、操作説明 |
| **Release / DevOps（リリース担当）** | **GPT-6 Sol** | Build、CI、Deployment、リリース確認 |
| **Final Reviewer（最終チェック担当）** | **NVIDIA別系列モデル** | 実装担当とは異なるモデルで独立レビュー |
| **Escalation（難問解決担当）** | **GPT-6 Astra / Claude Opus 最新安定版** | 通常チームで解けない難問のみ |

Claudeの具体的なバージョンIDは、実装時に利用可能な最新安定版を確認して設定する。モデル名をコードへ過度に固定せず設定で交換可能にする。

## 5. NVIDIA無料Hosted APIの使い方

NVIDIA Developer Programの無料Hosted Endpointは、V3.1では**主系統ではなく補助部隊**として扱う。

無料Endpointは混雑・rate limit・throttling・応答時間の変動があり得るため、NVIDIAの返答がないと開発フロー全体が止まる設計にはしない。

### NVIDIA候補

| NVIDIA枠 | 候補モデル | 用途 |
|---|---|---|
| **Fast Agent（高速補助担当）** | **Nemotron Lightning系** | 軽量Agent処理、並列補助 |
| **Coding Agent（コード補助担当）** | **Laguna XS 2.1** | Agentic coding、terminal系の補助 |
| **Reasoning / Final Review（推論・最終確認担当）** | **Nemotron 3 Super 120B系** | 別系列からの推論・最終レビュー |
| **Brainstorm（発想担当）** | **Kimi系 / GLM系 / Nemotron系** | GPT/Claudeとは異なる視点を追加 |
| **Deep Reasoner（難問検証担当）** | **Nemotron Ultra系** | 通常モデルで解けない問題のみ |

NVIDIAモデル名・無料提供状況は変動し得るため、利用時にAPI Catalogで確認する。

### NVIDIA Failure / Fallback

```text
NVIDIAへ依頼
    ↓
正常応答 ─────→ 結果を利用
    ↓
429 / timeout / 長時間待機
    ↓
Retry（上限あり）
    ↓
まだ失敗
    ↓
NVIDIA担当をSkip
    ↓
GPT / Claude側で処理継続
```

NVIDIA無料APIをクリティカルパスに置かない。

## 6. NVIDIAモデル実測ベンチマーク

カタログ上の性能だけで担当を固定しない。同一プロンプトを候補モデルへ複数回送り、実環境で比較する。

記録候補:

- Time to First Token（初動時間）
- Total Response Time（完了時間）
- 429発生率
- Timeout率
- 成功率
- 出力品質
- Coding成功率
- Tool利用成功率
- 長時間Agent Task成功率

実測結果からNVIDIA担当モデルを入れ替えられるようにする。

## 7. Core Skills（基本技能）

- Refactoring（コード整理）
- Testing（テスト）
- Debugging（バグ解析）
- Code Review（コードレビュー）
- Security Review（セキュリティレビュー）
- Git
- Documentation（文書化）
- Research（調査）
- Architecture（設計）
- Dependency Review（依存関係確認）
- Release Check（リリース確認）

## 8. Core Recipes（基本手順）

### Feature Recipe（新機能開発）

```text
依頼 → Goose分類 → 必要なら調査 → 設計 → 実装 → テスト
→ 品質確認 → 必要ならセキュリティ確認 → 必要ならリファクタ
→ 回帰テスト → 最終レビュー → ドキュメント → Human Gate → PR/Release
```

### Bugfix Recipe（バグ修正）

```text
バグ報告 → 再現 → 切り分け → 根本原因 → 修正
→ テスト → 回帰テスト → 品質/セキュリティ確認 → 最終レビュー
```

### Refactor Recipe（コード整理）

```text
対象分析 → 現在の挙動をテストで保護 → 改善点抽出
→ Refactor → Test → Regression → Quality Review → Final Review
```

原則として外部仕様・ユーザーから見える挙動を変えない。

### Brainstorm Recipe（アイデア出し）

**Phase 1: 発散**  
同じ課題をGPT、Claude、NVIDIA系など複数AIへ渡し、実現性で早期に絞りすぎず案を出す。

**Phase 2: 統合**  
Gooseが重複整理、グループ化、組合せ、独自性・ユーザー価値を整理。

**Phase 3: 実現可能性検証**  
各案を以下へ分類する。

- **Implementable Now（今すぐ実装可能）**
- **Needs Research（追加調査が必要）**
- **Blocked / Difficult（現状では困難）**

必要技術、変更範囲、リスク、外部依存、おおまかな実装方針も整理する。

**Phase 4: Human Choice（人間が選択）**  
Gooseが勝手に新機能を選んで実装せず、ユーザーが選んだ案をFeature Recipeへ渡す。

## 9. Dynamic Routing（動的振り分け）

### Small（小規模）

```text
Goose → Implementer（実装） → Tester（テスト）
```

### Standard（標準）

```text
Goose
 → Architect（設計）
 → Implementer（実装）
 → Tester（テスト）
 → Quality Reviewer（品質確認）
 → Final Reviewer（最終確認）
```

### High Risk / Complex（高リスク・複雑）

```text
Goose
 → Researcher（調査）
 → Architect（設計）
 → Implementer（実装）
 → Tester（テスト）
 → Quality Reviewer（品質確認）
 + Security Reviewer（セキュリティ確認）
 → Regression Test（回帰テスト）
 → Final Reviewer（最終確認）
 → Documentation（文書更新）
```

## 10. Model Routing（モデル振り分け）

1. 軽量・大量処理はLuna系を優先。
2. 通常の司令・実装はSol系を中心にする。
3. 難しい設計・重要レビューにはOpus等の高能力モデルを必要時のみ使う。
4. 超難問のみAstra等へEscalation。
5. 実装者とReviewerは可能な限り別モデル・別系列にする。
6. Brainstormではモデル間の違いを積極利用。
7. NVIDIA無料Endpointは補助・並列・別視点に使い、失敗時は主系統を継続。
8. 将来は品質・速度・コスト・成功率・rate limit実績から自動Routingする。

## 11. Quality Gate（品質ゲート）

- 要件を満たす
- Build成功
- Test成功
- Regressionなし
- 不要変更なし
- 理解可能なコード
- 過剰な重複なし
- エラー処理が適切
- ドキュメントと矛盾しない

重大問題があれば完了扱いにしない。

## 12. Security Gate（セキュリティゲート）

確認対象:

- Secrets
- Authentication / Authorization
- Input validation
- Injection
- File / Network access
- Dependency risk
- Sensitive logs
- Unsafe defaults
- Permission escalation

Security Reviewerは「安全」と断言するのではなく、確認範囲・発見事項・残存リスクを報告する。

## 13. Git Workflow

```text
Task → Branch → Implementation → Test → Quality Gate
→ Security Gate（必要時） → Final Review → Commit
→ Pull Request → Human Approval → Merge
```

意味のある変更をAIが無条件でmainへ直接書き込む運用は避ける。

## 14. Failure Handling（失敗処理）

1. エラー内容を保存
2. 原因分析
3. 修正を試す
4. 必要なら別Role / Modelへ切替
5. 初期値3回で解決しなければHuman Gate

同じ操作を意味なく繰り返さない。

## 15. Definition of Done（完了条件）

- 要求を満たしている
- 必要なテスト成功
- Regression確認済み
- Quality Gate通過
- 必要なSecurity Gate通過
- 重大な未解決事項なし
- 必要なDocumentation更新済み
- 変更内容を説明可能
- Human Gate対象なら承認済み

## 16. V3.1 検証項目

- **Routing（振り分け）**: 不要なAgentを呼ばず、必要な担当を招集できるか。
- **Multi-Agent（複数AI）**: 結果回収、矛盾整理、重複回避ができるか。
- **Brainstorm（発想）**: 十分に異なる案を出し、発想と実現性評価を分離できるか。
- **Quality（品質）**: 独立レビューとRegression検出が機能するか。
- **Security（安全性）**: 高リスク変更を検知し専用担当を呼べるか。
- **Human Gate（人間判断）**: 無限ループ・危険操作を止められるか。
- **Cost / Speed（コスト・速度）**: 小タスクへ高価なモデルを乱用していないか。
- **NVIDIA Endpoint**: 応答時間、429、timeout、成功率を測定し、無料Endpoint障害で全体が停止しないか。

## 17. 初期実装優先順位

**Phase 1**: Goose Orchestrator、Dynamic Routing、Feature/Bugfix/Refactor/Brainstorm Recipe。

**Phase 2**: Tester、Quality Reviewer、Security Reviewer、Final Reviewer、Human Gate。

**Phase 3**: Model Routing、Parallel Agent execution、NVIDIA fallback/benchmark、Dependency Reviewer、Documentation、Release/DevOps。

**Phase 4**: コスト最適化、モデル成功率記録、過去タスクからRouting改善、Recipe追加・改善。

## 18. V3.1 全体像

```text
                         User
                          ↓
                 Goose / GPT-6 Sol
                    【司令塔】
                          │
              Task Classification
                          │
       ┌──────────────────┼──────────────────┐
       ↓                  ↓                  ↓
 GPT-6 Luna       Claude Opus         Brainstorm Team
【調査担当】         【設計担当】       【複数AIで発想】
       └──────────────────┼──────────────────┘
                          ↓
                     GPT-6 Sol
                     【実装担当】
                          ↓
              GPT-6 Luna + NVIDIA補助
                     【テスト担当】
                          ↓
                   Claude Sonnet
                    【品質確認】
                          │
                ┌─────────┴─────────┐
                ↓                   ↓
          Claude Opus          NVIDIA別系列
      【セキュリティ担当】       【最終確認】
                │                   │
                └─────────┬─────────┘
                          ↓
                        Goose
                          ↓
                    Human Gate
                          ↓
                     PR / Release

NVIDIA無料Endpoint:
高速補助 / コード補助 / Brainstorm / 別視点レビュー
        ↓ 429・timeout時
     Retry（上限あり）
        ↓
     Skip / GPT・ClaudeへFallback
```

## 19. V3.1 の目標

**必要なときに、必要な専門家を、必要なだけ呼び、GPT・Claude・NVIDIA系モデルの強みを相互補完しながら、安全かつ高品質に開発を進める。**

ユーザーは内部のモデル割り振りを毎回考える必要はない。Gooseが自然言語の目的を開発プロセスへ変換し、コスト・速度・品質・利用制限を考慮してチームを編成する。
