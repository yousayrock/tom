<div align="center">

# トム

_日本語で考え、日本語で仕事を進めるオープンソースAIエージェント_

<p align="center">
  <a href="https://opensource.org/licenses/Apache-2.0"
    ><img src="https://img.shields.io/badge/License-Apache_2.0-blue.svg"></a>
</p>

</div>

トムは、[goose](https://github.com/aaif-goose/goose)を基盤に、対話・文書作成・調査・開発作業を日本語で自然に進められることを目指したディストリビューションです。

現在は初期開発段階です。内部のcrate名や設定キーには、上流gooseとの互換性を保つため`goose`の名称が残っています。変更方針と進捗は[TOM.md](TOM.md)を参照してください。

## トムのCLIを試す

```bash
source bin/activate-hermit
just build-tom
./target/debug/tom --help
```

設定ファイルと環境変数は、上流互換性のため引き続き`GOOSE_*`を使用します。

## Upstream (goose)

gooseは、あなたのマシン上で動く汎用AIエージェントです。コードだけでなく、調査、文章作成、自動化、データ分析など、やりたいことは何でもこなせます。

macOS・Linux・Windows向けのネイティブデスクトップアプリ、ターミナル作業向けのフルCLI、どこにでも組み込めるAPIを提供します。パフォーマンスと移植性のためRustで構築されています。

gooseは15以上のプロバイダー（Anthropic、OpenAI、Google、Ollama、OpenRouter、Azure、Bedrockなど）に対応しています。APIキー、または既存のClaude・ChatGPT・Geminiのサブスクリプションを[ACP](https://goose-docs.ai/docs/guides/acp-providers)経由で利用できます。[Model Context Protocol](https://modelcontextprotocol.io/)というオープン標準で70以上の拡張機能に接続できます。

gooseはLinux Foundation傘下の[Agentic AI Foundation (AAIF)](https://aaif.io/)の一部です。

# はじめる

**[デスクトップアプリをダウンロード](https://goose-docs.ai/docs/getting-started/installation)**（macOS・Linux・Windows対応）

またはCLIをインストール:

```bash
curl -fsSL https://github.com/aaif-goose/goose/releases/download/stable/download_cli.sh | bash
```

# クイックリンク
- [クイックスタート](https://goose-docs.ai/docs/quickstart)
- [インストール](https://goose-docs.ai/docs/getting-started/installation)
- [チュートリアル](https://goose-docs.ai/docs/category/tutorials)
- [ドキュメント](https://goose-docs.ai/docs/category/getting-started)
- [ガバナンス](https://github.com/aaif-goose/goose/blob/main/GOVERNANCE.md)
- [カスタムディストリビューション](https://github.com/aaif-goose/goose/blob/main/CUSTOM_DISTROS.md) — 独自のプロバイダー・拡張機能・ブランディングを設定した、あなただけのgooseディストリビューションを作る（トムはこの仕組みで作られている）

## 困ったときは
- [診断とレポート](https://goose-docs.ai/docs/troubleshooting/diagnostics-and-reporting)
- [既知の問題](https://goose-docs.ai/docs/troubleshooting/known-issues)

# ちょっとしたgooseジョーク 🪿

> 開発者がAIエージェントにgooseを選んだ理由は？
>
> いつも本番環境へのコードの「migrate（渡り）」を手伝ってくれるから！🚀
> （gooseは渡り鳥。"migrate"には「移行する」と「渡りをする」の両方の意味がある）

# goose関連リンク
- [Discord](https://discord.gg/n8R5VaWDAn)
- [YouTube](https://www.youtube.com/@goose-oss)
- [LinkedIn](https://www.linkedin.com/company/goose-oss)
- [Twitter/X](https://x.com/goose_oss)
