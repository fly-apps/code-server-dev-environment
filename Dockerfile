FROM lubien/tired-proxy:2 as proxy
FROM hexpm/elixir:1.12.3-erlang-24.1.4-debian-bullseye-20210902-slim

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git \
    && apt-get clean && rm -f /var/lib/apt/lists/*_* \
    && apt update \
    && apt install curl --yes \
    && apt-get install unzip -y \
    && curl -fsSL https://code-server.dev/install.sh | sh

# prepare build dir
WORKDIR /app

# Use bash shell
ENV SHELL=/bin/bash

# Apply VS Code settings
COPY settings.json /root/.local/share/code-server/User/settings.json

# Use our custom entrypoint script first
COPY entrypoint.sh /entrypoint.sh

RUN curl -L https://fly.io/install.sh | sh \
    && echo 'export FLYCTL_INSTALL="/root/.fly"' >> ~/.bashrc \
    && echo 'export PATH="$FLYCTL_INSTALL/bin:$PATH"' >> ~/.bashrc \
    && code-server --install-extension elixir-lsp.elixir-ls

COPY --from=proxy /tired-proxy /tired-proxy

ENTRYPOINT ["/entrypoint.sh"]