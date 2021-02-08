#!/bin/bash
set -eo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 semver"
    exit 1
fi
version=$1
if [[ ! $version =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    echo "Error: You must specify a version on the form MAJOR.MINOR.PATCH"
    exit 1
fi

# No CGO here
export CGO_ENABLED=0

function build_windows() {
    export GOOS=$1
    export GOARCH=$2

    echo "Building $GOOS $GOARCH"

    mkdir tmp_build

    # Do a parallel build
    go build -ldflags "-s -w" -o tmp_build/agent.exe agent/cmd/win32service
    wait

    mkdir dist/agent-${GOOS}-${GOARCH}-${version}
    mv -v tmp_build/* dist/agent-${GOOS}-${GOARCH}-${version}
}

echo Building agents with `go version`

mkdir dist

build_windows windows amd64

