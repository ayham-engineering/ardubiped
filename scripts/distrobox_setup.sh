#!/usr/bin/env bash
set -euo pipefail

BOX_NAME="ardubiped"
IMAGE="docker.io/library/ubuntu:24.04"
SENTINEL="/opt/ardubiped_setup_done"

if [ -n "${DISTROBOX_ENTER_PATH:-}" ] || [ -f "/run/.containerenv" ]; then
    echo "[setup] Running inside distrobox – starting install..."

    if [ -f "$SENTINEL" ]; then
        echo "[setup] Already set up. Nothing to do."
        exit 0
    fi

    export DEBIAN_FRONTEND=noninteractive

    sudo apt-get update -y
    sudo apt-get install -y --no-install-recommends \
        curl wget git cmake ninja-build build-essential \
        python3 python3-pip python3-dev \
        lsb-release gnupg ca-certificates tmux \
        gawk gcc g++ \
        python3-serial python3-numpy \
        python3-pyparsing python3-psutil python3-pexpect \
        rapidjson-dev

    curl -fsSL https://packages.osrfoundation.org/gazebo.gpg \
        | sudo tee /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg > /dev/null
    echo "deb [arch=$(dpkg --print-architecture) \
signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] \
http://packages.osrfoundation.org/gazebo/ubuntu-stable \
$(lsb_release -cs) main" \
        | sudo tee /etc/apt/sources.list.d/gazebo-stable.list

    sudo apt-get update -y
    sudo apt-get install -y --no-install-recommends \
        gz-harmonic \
        libgz-sim8-dev libgz-msgs10-dev libgz-transport13-dev

    sudo git clone --depth 1 \
        https://github.com/ArduPilot/ardupilot_gazebo.git \
        /opt/ardupilot_gazebo
    cd /opt/ardupilot_gazebo
    sudo mkdir -p build && cd build
    sudo cmake .. -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo
    sudo ninja -j"$(nproc)"

    pip3 install --break-system-packages \
        "empy==3.3.4" ptyprocess future mavproxy pyserial

    sudo git clone --depth 1 \
        https://github.com/ArduPilot/ardupilot.git \
        /opt/ardupilot
    cd /opt/ardupilot
    sudo git submodule update --init --recursive --depth 1
    sudo chown -R "$(id -u):$(id -g)" /opt/ardupilot
    ./waf configure --board sitl
    ./waf rover

    sudo touch "$SENTINEL"
    echo ""
    echo "  Setup complete!  Now run:  ./scripts/run_local.sh"
    exit 0
fi

echo "[setup] On Fedora host – managing distrobox '${BOX_NAME}'..."

if distrobox list 2>/dev/null | grep -q "$BOX_NAME"; then
    if distrobox enter "$BOX_NAME" -- test -f "$SENTINEL" 2>/dev/null; then
        echo "[setup] Already fully set up. Nothing to do."
        exit 0
    else
        echo "[setup] Incomplete setup – removing box and starting fresh..."
        distrobox rm --force "$BOX_NAME"
    fi
fi

distrobox create --name "$BOX_NAME" --image "$IMAGE" --yes

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "[setup] Entering box to install (this takes ~15 min)..."
distrobox enter "$BOX_NAME" -- bash "${REPO_ROOT}/scripts/distrobox_setup.sh"
