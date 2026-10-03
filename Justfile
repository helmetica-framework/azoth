chart := `awk '/^name:/{print $2}' Chart.yaml`
version := `awk '/^version:/{print $2}' Chart.yaml`

REGISTRY := "oci://ghcr.io/helmetica-framework"

# renovate: datasource=github-releases depName=helm-unittest/helm-unittest
UNITTEST_VERSION := "v1.2.1"

_default:
    @just --list

# Lint the chart and unit test its templates through the fixture in test/fixture
test:
    #!/usr/bin/env bash
    set -euo pipefail
    helm plugin list | grep -q '^unittest' \
        || helm plugin install https://github.com/helm-unittest/helm-unittest --version {{ UNITTEST_VERSION }}
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
