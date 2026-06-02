#!/usr/bin/env bash

# Source this file from ~/.bashrc to reproduce the local robotics workspace layout.
export PATH="$HOME/.pixi/bin:$PATH"

export PROJECTS_DIR="${PROJECTS_DIR:-$HOME/Projects}"
export UNITREE_GO2_ROOT="${UNITREE_GO2_ROOT:-$PROJECTS_DIR/Unitree_Go2}"
export REPO="${REPO:-$UNITREE_GO2_ROOT}"
export ISAACLAB_ROOT="${ISAACLAB_ROOT:-$PROJECTS_DIR/IsaacLab}"
export UNITREE_RL_LAB_ROOT="${UNITREE_RL_LAB_ROOT:-$UNITREE_GO2_ROOT/training/isaac_lab/unitree_rl_lab}"
export OMX_F_ISAACLAB_ROOT="${OMX_F_ISAACLAB_ROOT:-$ISAACLAB_ROOT/omx_f_isaaclab}"
export OPEN_MANIPULATOR_ROOT="${OPEN_MANIPULATOR_ROOT:-$PROJECTS_DIR/open_manipulator}"
export ROS2_WS="${ROS2_WS:-$PROJECTS_DIR/ros2_ws}"
export GO2_ROUGHNAV_ROOT="${GO2_ROUGHNAV_ROOT:-$UNITREE_GO2_ROOT/ros2/go2_roughnav}"

source_if_exists() {
    [ -f "$1" ] && . "$1"
}

source_if_exists /opt/ros/jazzy/setup.bash
source_if_exists "$ROS2_WS/install/setup.bash"
source_if_exists "$GO2_ROUGHNAV_ROOT/install/setup.bash"

unalias go2 go2repo go2rl go2ros omxlab omxsrc killisaac 2>/dev/null || true

go2() {
    cd "$UNITREE_RL_LAB_ROOT/docker" || return
    docker compose --env-file .env.base up -d
    docker compose --env-file .env.base exec isaac-lab-template bash
}

go2repo() { cd "$UNITREE_GO2_ROOT"; }
go2rl() { cd "$UNITREE_RL_LAB_ROOT"; }
go2ros() { cd "$GO2_ROUGHNAV_ROOT"; }
omxlab() { cd "$OMX_F_ISAACLAB_ROOT"; }
omxsrc() { cd "$OPEN_MANIPULATOR_ROOT"; }

killisaac() {
    sudo pkill -9 -f "kit"
    sudo pkill -9 -f "isaac"
    sudo pkill -9 -f "train.py"
}
