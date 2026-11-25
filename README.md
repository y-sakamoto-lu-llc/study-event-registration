# 勉強会の参加登録（AI駆動開発入門のサンプルアプリ）

連載「AI駆動開発入門」のワークで使う Rails アプリです。勉強会の主催者がイベントを公開し、参加者が参加登録・キャンセルできます。

この初期状態では、**参加登録にルールがありません**（定員・申込締切・重複登録のチェックがない）。これらは連載のワークで Claude Code と一緒に作っていきます。

## 動かし方

```sh
bin/setup          # 依存関係のインストール、DB の作成、シードの投入、サーバー起動
```

- http://localhost:3000 を開きます。
- シードのユーザーはすべてパスワード `password` です（例: `organizer@example.com`）。
- 開発環境で送ったメールは http://localhost:3000/letter_opener で確認できます。
- credentials（`config/credentials.yml.enc`）はリポジトリに含めていません。必要になったら `bin/rails credentials:edit` で各自作成します（連載の STEP 2 で扱います）。

## テストとチェック

```sh
bundle exec rspec    # テスト
bin/rubocop          # スタイルチェック
bin/brakeman         # セキュリティの静的解析
bin/ci               # 上の3つを含むチェック一式
```

## 構成

| モデル | 役割 |
| --- | --- |
| User | ユーザー（Rails 8 の認証ジェネレーター） |
| Event | イベント。定員（`capacity`）と申込締切（`registration_deadline`）の列はあるが、まだ使っていない |
| Registration | 参加登録。状態は「登録済み」「キャンセル」 |

## 各章の開始地点

連載の各章は `step-02-start` のようなタグから始められます（章の公開に合わせて追加します）。
