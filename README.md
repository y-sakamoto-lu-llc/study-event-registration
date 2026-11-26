# 勉強会の参加登録（AI駆動開発入門のサンプルアプリ）

連載「AI駆動開発入門」のワークで使う Rails アプリです。勉強会の主催者がイベントを公開し、参加者が参加登録・キャンセルできます。

この初期状態では、**参加登録にルールがありません**（定員・申込締切・重複登録のチェックがない）。これらは連載のワークで Claude Code と一緒に作っていきます。

## 動かし方

Dev Container で動かします。Ruby や Node.js を手元に入れる必要はありません。

### 用意するもの

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)（または互換の Docker 環境）
- [VS Code](https://code.visualstudio.com/) と拡張機能 [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### 起動する

1. このリポジトリを自分のアカウントにフォークし、フォークしたリポジトリをクローンします。連載の後半で、自分のリポジトリに push したり PR を作ったりするためです。
   ```sh
   git clone https://github.com/<自分のアカウント>/study-event-registration.git
   cd study-event-registration
   git remote add upstream https://github.com/y-sakamoto-lu-llc/study-event-registration.git
   git fetch upstream --tags   # 章の開始地点のタグを取り込む
   ```
   クローンしたフォルダを VS Code で開きます（Cursor でも同じ手順で進められます）。
2. 右下の通知、またはコマンドパレットの「Dev Containers: Reopen in Container」を選びます。
3. 初回はイメージの作成と `bin/setup --skip-server`（gem のインストールと DB の準備）が自動で走ります。
4. VS Code のターミナル（コンテナの中）で次を実行します。

```sh
bin/dev            # サーバー起動
claude             # Claude Code を起動（初回はログインが必要）
```

コンテナには Ruby・SQLite・Node.js・Claude Code が入っています。Claude Code のログイン情報はボリュームに保存されるので、コンテナを作り直しても残ります。

### サーバーが立ち上がったら

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

連載の各章は `step-04-start` のようなタグから始められます（章の公開に合わせて追加します）。新しく追加されたタグは `git fetch upstream --tags` で取り込めます。
