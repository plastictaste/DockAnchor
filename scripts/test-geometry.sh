#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build/geometry-tests
cp scripts/geometry-tests.swift build/geometry-tests/main.swift
swiftc -module-cache-path build/ModuleCache DockAnchor/RelocationGeometry.swift build/geometry-tests/main.swift -o build/geometry-tests/run
build/geometry-tests/run
