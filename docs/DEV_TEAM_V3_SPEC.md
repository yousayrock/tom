# Dev Team V3 仕様書・設計書

> Status: Draft / Validation Specification  
> Target: TOM  
> Version: Dev Team V3  
> Updated: 2026-09-23

## 1. 目的

Dev Team V3 は、Goose を単なるコーディングAIではなく、複数のAI・専門ロール・Skill・Recipeを必要に応じて編成する **Orchestrator（司令塔）** として動かすための開発チーム設計である。

ユーザーは細かな担当割り振りを意識せず、「この機能を作りたい」「このバグを直して」「何か面白いアイデアない？」のような自然な依頼を行う。

Goose が依頼を分析し、必要な担当だけを招集し、調査・設計・実装・検証・レビューまでを進行する。

---

## 2. V3 の基本原則

### 2.1 Dynamic Team

毎回すべてのAgentを動かさない。

Goose がタスクの難易度、変更範囲、リスク、専門性を判断し、必要な担当だけを選ぶ。

例:

- 軽微な修正 → Goose / Implementer / Test
- 通常の新機能 → Architect / Implementer / Tester / Quality Reviewer
- 認証・外部APIなど → Researcher / Architect / Implementer / Tester / Security Reviewer / Quality Reviewer / Final Reviewer

### 2.2 Quality Gate

「コードが動いた」だけでは完了としない。

必要な品質チェック、テスト、レビューを通過して初めて完了候補とする。

### 2.3 Security Gate

セキュリティ上のリスクがある変更では専用チェックを必須化する。

特に以下を確認する。

- APIキー・Token・Passwordなど秘密情報の漏洩
- 認証・認可
- 入力値検証
- 外部通信
- 権限
- 依存パッケージ
- 一般的な脆弱性
- ログへの秘密情報出力

### 2.4 Human Gate

AIだけで無限ループしない。

同じ問題で一定回数（初期値: 3回）失敗した場合は処理を停止し、以下をユーザーへ報告する。

- 何をしようとしたか
- どこで失敗したか
- 試した対策
- 現在の仮説
- 人間に判断してほしい事項

危険性の高い操作、破壊的変更、重要な仕様判断についてもHuman Gateを利用する。

---

## 3. Agent / Role / Skill / Recipe の分離

V3では以下を明確に分ける。

- **Agent / Role** = 誰が担当するか
- **Skill** = どう上手に作業するか
- **Recipe** = どの順番で仕事を進めるか
- **Model** = どのAIに処理させるか

Roleと特定モデルを固定しすぎない。

同じRoleでも、タスクや利用可能なAIに応じてClaude、Codex、NVIDIA API上のモデル等を切り替えられる設計を目指す。

---

## 4. Goose / Orchestrator

Goose は Dev Team V3 の中心となる。

### 主な責務

1. ユーザー要求の受付
2. リポジトリ・現状の把握
3. タスク分類
4. 難易度・リスク判定
5. Recipe選択
6. 必要なRole選択
7. モデル選択
8. タスク分解
9. 並列化可能性の判断
10. 各Agentへの指示
11. 結果回収
12. 衝突・矛盾の整理
13. Quality / Security Gateの実施判断
14. Human Gateの判断
15. 最終結果のユーザーへの提示

Goose自身で十分な軽微作業については、無理に別Agentを呼び出さない。

---

## 5. Role 一覧

### Orchestrator

Goose。チーム全体の司令塔。

### Researcher

- 技術調査
- 既存コード調査
- ライブラリ調査
- API調査
- 実装方法候補の比較

### Brainstorm Team

複数AIによる発想チーム。

単一のAIに依存せず、Claude、Codex、NVIDIA API上の複数モデルなど、利用可能なAIから異なる視点のアイデアを集める。

### Architect

- 要件整理
- 全体設計
- 技術選定
- インターフェース設計
- 変更範囲決定
- 実装計画作成

### Implementer

- コード実装
- 必要なテスト追加
- Architectの設計に基づく変更

### Debugger

- 不具合再現
- 原因切り分け
- 根本原因分析
- 修正案作成
- 修正後の再確認

### Tester

- Unit Test
- Integration Test
- Regression Test
- 主要動作確認
- エッジケース確認

### Refactorer

機能を原則変えずにコードを改善する。

- 重複削減
- 関数・責務分割
- 命名改善
- 可読性改善
- 複雑性削減
- 不要コード整理

### Quality Reviewer

- 可読性
- 保守性
- 複雑性
- 重複
- エラー処理
- 設計との整合
- テスト不足
- 不要な変更
- 将来の変更容易性

### Security Reviewer

- 秘密情報
- 認証・認可
- 入力検証
- Injection系リスク
- 外部通信
- 権限
- 依存関係
- セキュリティ上危険な実装

### Dependency Reviewer

- パッケージ依存関係
- バージョン
- 不要依存
- 既知の問題
- ライセンス
- 更新による影響

### Documentation

- README
- 仕様書
- 設計書
- 操作方法
- 変更内容
- 開発者向けドキュメント

をコードと同期させる。

### Release / DevOps

- Build
- CI
- Release前チェック
- 設定確認
- Deployment準備
- リリース手順確認

### Final Reviewer

実装担当とは異なる視点で最終確認を行う。

可能であれば、実装に使ったモデルとは別モデルを利用する。

---

## 6. Core Skills

初期Skill候補:

- Refactoring
- Testing
- Debugging
- Code Review
- Security Review
- Git
- Documentation
- Research
- Architecture
- Dependency Review
- Release Check

SkillはRoleから再利用できるようにする。

---

## 7. Core Recipes

V3初期版では以下を主要Recipeとする。

### 7.1 Feature Recipe

```text
Request
  ↓
Gooseによる分類
  ↓
必要ならResearch
  ↓
Architecture
  ↓
Implementation
  ↓
Test
  ↓
Quality Check
  ↓
必要ならSecurity Check
  ↓
必要ならRefactor
  ↓
Regression Test
  ↓
Final Review
  ↓
Documentation
  ↓
Human/User確認
  ↓
Release / Merge
```

### 7.2 Bugfix Recipe

```text
Bug Report
  ↓
再現
  ↓
原因切り分け
  ↓
Root Cause
  ↓
修正
  ↓
Test
  ↓
Regression Test
  ↓
Quality / Security Check
  ↓
Final Review
```

単に症状を消すのではなく、可能な限り根本原因を特定する。

### 7.3 Refactor Recipe

```text
対象分析
  ↓
現在の挙動をテストで保護
  ↓
改善点抽出
  ↓
Refactoring
  ↓
Test
  ↓
Regression Test
  ↓
Quality Review
  ↓
Final Review
```

原則として外部仕様・ユーザーから見える挙動を変えない。

### 7.4 Brainstorm Recipe

V3の重要Recipe。

ユーザーは非常に曖昧な依頼でもよい。

例:

> 「TOMに何か面白い機能ない？」

#### Phase 1: Divergence / 発散

Goose が複数のAIを呼び、同じテーマについて自由に案を出させる。

```text
User
 ↓
Goose
 ├─ Claude
 ├─ Codex
 ├─ NVIDIA Model A
 ├─ NVIDIA Model B
 └─ その他利用可能なAI
```

この段階では「実装できるか」を厳しく制限しすぎない。

目的は異なるモデル・異なる視点から発想を広げること。

#### Phase 2: Synthesis / 統合

Goose が全案を回収し、

- 重複整理
- 類似案のグループ化
- アイデア同士の組み合わせ
- 独自性の整理
- ユーザー価値の整理

を行う。

#### Phase 3: Feasibility / 実現可能性検証

発想後に初めて技術面を検証する。

各案を原則として以下へ分類する。

- **Implementable Now** — 現在の構成で実装可能
- **Needs Research** — 追加調査・PoCが必要
- **Blocked / Difficult** — 現状の制約では難しい

併せて、

- 必要技術
- 変更範囲
- 主なリスク
- 外部依存
- おおまかな実装方針

を整理する。

#### Phase 4: Human Choice

Gooseが勝手に新機能を選んで実装しない。

候補をユーザーへ提示し、人間が選択する。

選択された案はFeature Recipeへ渡す。

---

## 8. Dynamic Routing

タスクごとにチーム構成を変える。

### Level 1: Small

例: 文言修正、軽微なUI変更。

```text
Goose
 ↓
Implement
 ↓
Test
```

### Level 2: Standard

例: 通常の新機能。

```text
Goose
 ↓
Architect
 ↓
Implementer
 ↓
Tester
 ↓
Quality Reviewer
 ↓
Final Reviewer
```

### Level 3: High Risk / Complex

例: 認証、権限、重要データ、外部API、大規模変更。

```text
Goose
 ↓
Researcher
 ↓
Architect
 ↓
Implementer
 ↓
Tester
 ├─ Quality Reviewer
 └─ Security Reviewer
 ↓
Regression Test
 ↓
Final Reviewer
 ↓
Documentation
```

レベルは固定ルールだけではなく、Gooseが変更内容を見て引き上げられるようにする。

---

## 9. Model Routing

現在利用候補:

- Claude
- Codex
- NVIDIA API経由のモデル
- Gooseから利用可能なその他モデル

基本方針:

1. RoleとModelを完全固定しない
2. 軽い作業に高コストモデルを乱用しない
3. 難しい設計・推論には能力の高いモデルを選ぶ
4. コーディングではコード能力を重視する
5. Reviewでは可能なら実装者とは別モデルを使う
6. Brainstormではモデル間の違いを積極的に利用する
7. モデルが失敗した場合に別モデルへ切り替えられる構造を持つ

将来的にはコスト、速度、品質、コンテキスト量、成功率などから自動選択できるようにする。

---

## 10. Quality Gate

基本確認項目:

- 要件を満たしている
- Buildが通る
- Testが通る
- Regressionがない
- 不要な変更がない
- コードが理解可能
- 重複が過剰でない
- エラー処理が適切
- ドキュメントとの矛盾がない

重大な問題があれば完了扱いにしない。

---

## 11. Security Gate

高リスク変更では必須。

確認対象:

- Secrets
- Authentication
- Authorization
- Input validation
- Injection
- File access
- Network access
- Dependency risk
- Sensitive logs
- Unsafe defaults
- Permission escalation

Security Reviewerは「安全」と断言する役ではなく、確認した範囲、発見事項、残存リスクを報告する。

---

## 12. Git Workflow

原則:

```text
Task
 ↓
Branch
 ↓
Implementation
 ↓
Test
 ↓
Quality Gate
 ↓
Security Gate（必要時）
 ↓
Final Review
 ↓
Commit
 ↓
Pull Request
 ↓
Human Gate / Approval
 ↓
Merge
```

AIが無条件でmainへ直接変更する運用は避ける。

破壊的変更や重要変更では特にHuman Gateを必須とする。

---

## 13. Failure Handling

Agentが失敗した場合:

1. エラー内容を保存
2. 原因を分析
3. 修正を試す
4. 必要なら別Role / Modelへ切り替える
5. 初期値3回で解決しなければHuman Gate

同じ操作を意味なく繰り返さない。

---

## 14. 完了条件（Definition of Done）

タスクは必要な範囲で以下を満たして完了とする。

- 要求を満たしている
- 必要なテストが成功
- Regression確認済み
- Quality Gate通過
- 必要なSecurity Gate通過
- 重大な未解決事項がない
- 必要なDocumentation更新済み
- 変更内容を説明可能
- Human Gate対象なら承認済み

---

## 15. V3 検証項目

実装前後に以下を検証する。

### Routing

- Gooseは簡単な仕事で不要なAgentを呼ばないか
- 複雑な仕事で必要なRoleを呼べるか
- Securityが必要な変更を判定できるか

### Multi-Agent

- 複数AIの結果を正しく回収できるか
- 矛盾する意見を整理できるか
- 同じ仕事を無駄に重複させないか

### Brainstorm

- 複数モデルから十分に異なる案が出るか
- Gooseがアイデアを潰しすぎず整理できるか
- 発想と実現可能性評価を分離できるか
- 実装可能 / 要調査 / 困難へ分類できるか

### Quality

- 実装担当自身だけでレビューが完結していないか
- Regressionを検出できるか
- Refactorで挙動を壊さないか

### Security

- Secretsを検出できるか
- 高リスク変更でSecurity Reviewerが自動招集されるか
- リスクを見落とした場合に追加レビュー可能か

### Human Gate

- 無限修正ループを止められるか
- 失敗内容を人間に分かる形で説明できるか
- 危険な操作を勝手に実行しないか

### Cost / Speed

- 小さなタスクに大規模チームを使っていないか
- 並列化で速くなる部分を活用できるか
- 高性能モデルを必要な場所に限定できるか

---

## 16. V3 初期実装優先順位

### Phase 1

- Goose Orchestrator
- Dynamic Routing
- Feature Recipe
- Bugfix Recipe
- Refactor Recipe
- Brainstorm Recipe

### Phase 2

- Tester
- Quality Reviewer
- Security Reviewer
- Final Reviewer
- Human Gate

### Phase 3

- Model Routing
- Parallel Agent execution
- Dependency Reviewer
- Documentation
- Release / DevOps

### Phase 4

- コスト最適化
- モデル成功率の記録
- 過去タスクからのRouting改善
- Recipeの追加・自動改善

---

## 17. 最終イメージ

```text
                   User
                    ↓
                  Goose
              (Orchestrator)
                    ↓
          ┌── Task Classification ──┐
          ↓                         ↓
      Simple Task              Complex Task
          ↓                         ↓
     Minimum Team             Dynamic Team
                                    ↓
        ┌───────────────┬───────────┴───────────┐
        ↓               ↓                       ↓
     Research        Architecture            Brainstorm
        ↓               ↓                       ↓
        └──────────→ Implementation ←───────────┘
                        ↓
                      Test
                        ↓
              ┌─────────┴─────────┐
              ↓                   ↓
          Quality Gate       Security Gate
              └─────────┬─────────┘
                        ↓
                  Final Review
                        ↓
                   Human Gate
                        ↓
                 PR / Release
```

## 18. V3 の目標

Dev Team V3 のゴールは「AIをたくさん呼ぶこと」ではない。

**必要なときに、必要な専門家を、必要なだけ呼び、複数AIの強みを使いながら、安全かつ高品質に開発を進めること。**

ユーザーはAIチームの内部構造を細かく操作しなくても、目的を自然な言葉で伝えればよい。

Gooseがそれを開発プロセスへ変換する。
