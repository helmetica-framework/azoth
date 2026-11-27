chart := `awk '/^name:/{print $2}' Chart.yaml`
version := `awk '/^version:/{print $2}' Chart.yaml`

REGISTRY := "oci://ghcr.io/helmetica-framework"

# renovate: datasource=github-releases depName=helm-unittest/helm-unittest
UNITTEST_VERSION := "v1.1.2"

_default:
    @just --list

# Lint the chart and unit test its templates through the fixture in test/fixture
test:
    #!/usr/bin/env bash
    set -euo pipefail
    # Helm 4 verifies plugins on install, which a git source cannot satisfy. Helm 3 has
    # no --verify flag at all.
    verify=""
    helm version --template '{{ "{{" }} .Version {{ "}}" }}' | grep -q '^v3' || verify="--verify=false"
    helm plugin list | grep -q '^unittest' \
        || helm plugin install https://github.com/helm-unittest/helm-unittest --version {{ UNITTEST_VERSION }} $verify
    helm lint .
    # Nothing in a library chart renders on its own, so the tests run against a small
    # application chart that includes it.
    helm dependency update test/fixture
    helm unittest --file 'tests/*_test.yaml' test/fixture

# Package the chart
build:
    helm package .

# Push the packaged chart to the registry
push: build
    helm push {{ chart }}-{{ version }}.tgz {{ REGISTRY }}

# Push main, tag the current commit and push the tag to trigger the release
release:
    #!/usr/bin/env bash
    set -euo pipefail
    # Abort if the Chart.yaml version on main doesn't match the working copy.
    test "$(git show main:Chart.yaml | awk '/^version:/{print $2}')" = "{{ version }}" \
        || { echo "main Chart.yaml != working {{ version }}; commit the bump first"; exit 1; }
    # Abort if this version was already released.
    if git ls-remote --exit-code --tags origin "v{{ version }}" >/dev/null 2>&1; then
        echo "tag v{{ version }} already exists; bump the Chart.yaml version first"
        exit 1
    fi
    git push origin main
    git tag v{{ version }} main
    git push origin v{{ version }}

# Build the docs as they appear on docs.helmetica.io; fails on warnings
docs:
    GOPROXY=direct GOTOOLCHAIN=auto GOEXPERIMENT=jsonv2 go run github.com/helmetica-framework/rosarium@main preview . --kind chart

# Build the docs and serve them on http://localhost:2020
docs-serve:
    GOPROXY=direct GOTOOLCHAIN=auto GOEXPERIMENT=jsonv2 go run github.com/helmetica-framework/rosarium@main preview . --kind chart --serve :2020
