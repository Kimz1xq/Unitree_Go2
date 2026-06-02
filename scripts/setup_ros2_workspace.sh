#!/usr/bin/env bash
set -euo pipefail

REPO="${REPO:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

mkdir -p "${HOME}/go2_roughnav_ws/src" "${HOME}/go2_sim_ws/src"

ln -sfn "${REPO}/ros2/go2_roughnav" "${HOME}/go2_roughnav_ws/src/go2_roughnav"
ln -sfn "${REPO}/planning/trg_planner" "${HOME}/go2_sim_ws/src/TRG-planner-1"

cat <<EOF
ROS2 workspace links are ready.

go2_roughnav:
  ${HOME}/go2_roughnav_ws/src/go2_roughnav -> ${REPO}/ros2/go2_roughnav

TRG-planner:
  ${HOME}/go2_sim_ws/src/TRG-planner-1 -> ${REPO}/planning/trg_planner

Next:
  source /opt/ros/humble/setup.bash
  cd ${HOME}/go2_sim_ws/src/TRG-planner-1
  cmake -B cpp/trg_planner/build -S cpp/trg_planner -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${HOME}/go2_sim_ws/install/trg_planner_core
  cmake --build cpp/trg_planner/build -j\$(nproc)
  cmake --install cpp/trg_planner/build

  cd ${HOME}/go2_sim_ws
  export CMAKE_PREFIX_PATH=${HOME}/go2_sim_ws/install/trg_planner_core:\${CMAKE_PREFIX_PATH:-}
  colcon build --symlink-install --base-paths src/TRG-planner-1/pipelines/ros2 --cmake-args -DCMAKE_PREFIX_PATH=\$CMAKE_PREFIX_PATH

  source ${HOME}/go2_sim_ws/install/setup.bash
  cd ${HOME}/go2_roughnav_ws
  colcon build --symlink-install --packages-select go2_roughnav
EOF
