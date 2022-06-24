#!/bin/bash

TIME_TO_SHUTDOWN=3600

mkdir -p /project

# In case fly volumes put something there
rm -rf '/project/lost+found'

if [ -z "$(ls -A /project)" ]; then
    echo "Preparing project"

    rm -rf /project
    git clone $GIT_REPO /project

    cd /project

    echo "Setting up Elixir environment"

    mix local.hex --force
    mix local.rebar --force
    mix deps.get
fi

code-server --bind-addr 0.0.0.0:9090 /project &
    /tired-proxy --port 8080 --host http://localhost:9090 --time $TIME_TO_SHUTDOWN