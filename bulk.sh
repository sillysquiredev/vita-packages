#!/bin/bash

set -e

for dir in "$@"; do
    ./build.sh "$dir"
done   