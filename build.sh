#!/bin/bash

set -e

VITABUILD="${VITABUILD:-$VITASDK/vitabuild}"
_built=()

build_pkg() {
    local dir="$1"
    local pkgname
    pkgname=$(grep -m1 '^pkgname=' "$dir/PKGBUILD" | cut -d'"' -f2)

    # Skip if already built in this run
    for b in "${_built[@]}"; do
        [[ "$b" == "$pkgname" ]] && return
    done
    _built+=("$pkgname")

    # Parse depends
    local deps
    deps=$(grep -m1 '^depends=(' "$dir/PKGBUILD" | sed 's/depends=(//; s/)//' | tr -d "'\"")

    # Build dependencies first
    for dep in $deps; do
        local dep_dir="$VITABUILD/$dep"
        if [[ -d "$dep_dir" ]]; then
            build_pkg "$dep_dir"
        else
            echo "WARN: dependency '$dep' not found in $VITABUILD, skipping"
        fi
    done

    # Build this package
    pushd "$dir"
    vita-makepkg -C -f -d
    tar -C "$VITASDK" -xvf *-vita.pkg.tar.xz arm-vita-eabi
    popd
}

build_pkg "$1"   