#!/bin/bash

TIME_TO_SHUTDOWN="${IDLE_TIME_TO_SHUTDOWN:-120}"

mkdir -p /project

# In case fly volumes put something there
rm -rf '/project/lost+found'

if [ -z "$(ls -A /project)" ]; then
    echo "Preparing project"

    rm -rf /project
    git clone $GIT_REPO /project

    cd /project

    echo "Preparing README"

    # We need to use a temporary file because `sh` does not 
    # work properly rewritting files directly with `sed` not `tee`
    sed "s/\${FLY_CODE_URL}/https:\/\/${FLY_APP_NAME}.fly.dev/g" README.md | \
        sed "s/\${FLY_DEVELOPMENT_URL}/https:\/\/${FLY_APP_NAME}.fly.dev:4000/g" | \
        tee /tmp/README.md

    mv /tmp/README.md /project/README.md

    echo "Setting up Elixir environment"

    mix local.hex --force
    mix local.rebar --force
    mix deps.get
fi

code-server --bind-addr 0.0.0.0:9090 /project &
    /tired-proxy --port 8080 --host http://localhost:9090 --time $TIME_TO_SHUTDOWN