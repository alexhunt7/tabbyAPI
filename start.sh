#!/bin/bash

cd "$(dirname "$0")" || exit

VENV_DIR=".venv"

if ! command -v uv >/dev/null 2>&1; then
    echo "Could not find uv." >&2
    exit 1
fi

if [ -n "$CONDA_PREFIX" ]; then
    echo "It looks like you're in a conda environment. Skipping venv check."
else
    if [ ! -d "${VENV_DIR}" ]; then
        echo "Venv doesn't exist! Creating one for you."

        uv venv "${VENV_DIR}" -p 3.13

        if [ -f "start_options.json" ]; then
            echo "Removing old start_options.json"
            rm -rf start_options.json
        fi
    fi

    echo "Activating venv"

    # shellcheck source=/dev/null
    source "${VENV_DIR}/bin/activate"
fi

python3 start.py "$@"
