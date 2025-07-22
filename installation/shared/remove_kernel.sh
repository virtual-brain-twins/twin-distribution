#!/bin/bash

KERNEL_PATH=$(jupyter kernelspec list 2>/dev/null | grep -E '^\s*python3\s' | awk '{print $NF}')

if [ -n "$KERNEL_PATH" ] && [ -d "$KERNEL_PATH" ]; then
    rm -rf "$KERNEL_PATH" >/dev/null 2>&1
fi
