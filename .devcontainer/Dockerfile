# .ruby-version と同じバージョンにそろえる
ARG RUBY_VERSION=3.4.13
ARG NODE_VERSION=22

FROM node:${NODE_VERSION}-bookworm-slim AS node

FROM ruby:${RUBY_VERSION}-bookworm

# SQLite のコマンドと、vscode ユーザーが sudo を使うためのパッケージ
RUN apt-get update -qq \
  && apt-get install --no-install-recommends -y sqlite3 sudo less \
  && rm -rf /var/lib/apt/lists/*

# Claude Code は Node.js 22 以上が必要なので、公式イメージから Node.js だけを持ってくる
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -s ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

# Claude Code の CLI
RUN npm install -g @anthropic-ai/claude-code

# Gemfile.lock の BUNDLED WITH と同じ Bundler を入れる（Ruby に同梱の版との切り替えを起こさない）
COPY Gemfile.lock /tmp/Gemfile.lock
RUN gem install bundler -v "$(awk '/^BUNDLED WITH/ { getline; print $1 }' /tmp/Gemfile.lock)" \
  && rm /tmp/Gemfile.lock

# 作業用のユーザー（root で作業しない）
ARG USERNAME=vscode
RUN useradd --create-home --shell /bin/bash ${USERNAME} \
  && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
  && mkdir -p /home/${USERNAME}/.claude \
  && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.claude /usr/local/bundle
USER ${USERNAME}

# コンテナの外（ホストのブラウザ）から rails server に届くようにする
ENV BINDING="0.0.0.0"
