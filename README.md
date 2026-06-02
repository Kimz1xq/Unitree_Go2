# Unitree_Go2

Snapshot date: 2026-06-02

This repository packages the current Unitree Go2 work for ICROS/ICRA rough-terrain navigation:
IsaacLab/RSL-RL training, V5 policy artifacts, MuJoCo sim2sim, ROS2 teleop, FAST-LIO2 integration, TRG-planner integration, and competition map assets.

## Repository Layout

```text
Unitree_Go2/
├── unitree_rl_lab/        # IsaacLab + RSL-RL Go2 training, ROS2 bridge scripts
├── unitree_mujoco_go2/    # Go2 MuJoCo assets and scene XML files
├── go2_roughnav/          # ROS2 glue package for FAST-LIO2, TRG, cmd_vel, height_scan, RViz
├── TRG-planner-1/         # TRG-planner source, ROS2 pipeline, prebuilt map/config files
├── competition_maps/      # ICRA2023, ICRA2024, ICROS2025 map sources/assets
└── artifacts/
    ├── policies/v5_model_40000/
    │   ├── model_40000.pt
    │   ├── exported/policy.onnx
    │   ├── exported/policy.onnx.data
    │   └── params/
    └── slam_maps/         # Saved teleop map/debug outputs
```

Old/noisy materials were intentionally excluded: V2/V3/V4 experiment folders, training logs, build/install outputs, caches, TensorBoard event files, and unrelated checkpoints.

Important: the V5 ONNX export uses external data. Keep these two files in the same directory:

```text
artifacts/policies/v5_model_40000/exported/policy.onnx
artifacts/policies/v5_model_40000/exported/policy.onnx.data
```

## Runtime Split

Use two separate runtimes:

```text
IsaacLab container:
  - RL training and IsaacLab play
  - /isaac-sim/python.sh

ROS2 runtime:
  - MuJoCo sim2sim ROS2 bridge
  - FAST-LIO2
  - TRG-planner
  - teleop
  - RViz
```

The original local workspace used:

```text
Host repo path:     /home/nuri/Unitree_Go2
Isaac container:    /workspace/unitree_rl_lab
ROS_DOMAIN_ID:      42
RMW implementation: rmw_cyclonedds_cpp
```

Set the common ROS environment in each ROS terminal:

```bash
source /opt/ros/humble/setup.bash
export ROS_DOMAIN_ID=42
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
```

Host ROS Jazzy can be used for quick local checks if that is what the machine has installed, but the competition-oriented setup targets ROS2 Humble.

## IsaacLab Training

Inside the IsaacLab container, the project is expected at `/workspace/unitree_rl_lab`.

Train the current V5 experiment:

```bash
docker exec -it isaac-lab /isaac-sim/python.sh \
  /workspace/unitree_rl_lab/scripts/experiments/icros2026_v5/train.py \
  --task Unitree-Go2-ICROS2026-V5 \
  --headless
```

Train the V6 perceptive-real experiment:

```bash
docker exec -it isaac-lab /isaac-sim/python.sh \
  /workspace/unitree_rl_lab/scripts/experiments/icros2026_v6_perceptive_real/train.py \
  --task Unitree-Go2-ICROS2026-V6-PerceptiveReal \
  --headless
```

Play/evaluate V5 with a small number of environments:

```bash
docker exec -it isaac-lab /isaac-sim/python.sh \
  /workspace/unitree_rl_lab/scripts/experiments/icros2026_v5/play.py \
  --task Unitree-Go2-ICROS2026-V5 \
  --num_envs 8 \
  --lin_vel_x 1.0
```

Monitor a running V5 training log:

```bash
docker exec -it isaac-lab bash -lc \
  'tail -f /tmp/train_icros2026_v5.log'
```

## Export Policy

The packaged V5 40k policy is already available at:

```text
artifacts/policies/v5_model_40000/exported/policy.onnx
```

To export another checkpoint:

```bash
cd /home/nuri/Unitree_Go2/unitree_rl_lab
python3 scripts/export_onnx_standalone.py \
  --checkpoint /path/to/model_50000.pt \
  --out /home/nuri/Unitree_Go2/artifacts/policies/policy.onnx
```

## MuJoCo Sim2Sim

Run the V5 40k policy in MuJoCo without ROS:

```bash
cd /home/nuri/Unitree_Go2
python3 unitree_rl_lab/scripts/ros2/sim2sim_ros2.py \
  --onnx artifacts/policies/v5_model_40000/exported/policy.onnx \
  --map unitree_mujoco_go2/scene_icra2024_sloped.xml \
  --no-ros
```

Run sim2sim with ROS2 topics, LiDAR, and MuJoCo-generated height scan:

```bash
cd /home/nuri/Unitree_Go2
source /opt/ros/humble/setup.bash
export ROS_DOMAIN_ID=42
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

python3 unitree_rl_lab/scripts/ros2/sim2sim_ros2.py \
  --onnx artifacts/policies/v5_model_40000/exported/policy.onnx \
  --map unitree_mujoco_go2/scene_icra2024_sloped.xml \
  --lidar \
  --domain-id 42 \
  --publish-height-scan
```

Useful map choices:

```text
unitree_mujoco_go2/scene_icra2023_easy.xml
unitree_mujoco_go2/scene_icra2023_hard.xml
unitree_mujoco_go2/scene_icra2024_flat.xml
unitree_mujoco_go2/scene_icra2024_sloped.xml
unitree_mujoco_go2/scene_icros2025.xml
```

For FAST-LIO-owned odometry, let FAST-LIO publish `/Odometry` instead:

```bash
python3 unitree_rl_lab/scripts/ros2/sim2sim_ros2.py \
  --onnx artifacts/policies/v5_model_40000/exported/policy.onnx \
  --map unitree_mujoco_go2/scene_icra2024_sloped.xml \
  --lidar \
  --domain-id 42 \
  --no-fastlio-odom \
  --require-height-scan
```

## Teleop

Run keyboard teleop in a separate terminal:

```bash
cd /home/nuri/Unitree_Go2
source /opt/ros/humble/setup.bash
export ROS_DOMAIN_ID=42

python3 unitree_rl_lab/scripts/ros2/teleop_cmd_vel.py \
  --domain-id 42 \
  --max-lin 0 \
  --max-strafe 0 \
  --max-yaw 0
```

Key behavior:

```text
W/S: increase/decrease forward velocity
A/D: increase/decrease lateral velocity
Q/E: increase/decrease yaw rate
K:   zero velocity command
Space: publish robot reset on /go2/reset
Ctrl-C: quit
```

`--max-lin 0 --max-strafe 0 --max-yaw 0` disables teleop-side caps. Use this only in simulation.

## Teleop Map Accumulation

This records places visited through teleop by accumulating `/utlidar/cloud` using `/Odometry`.

Terminal 1, run sim2sim with LiDAR:

```bash
cd /home/nuri/Unitree_Go2
source /opt/ros/humble/setup.bash
export ROS_DOMAIN_ID=42

python3 unitree_rl_lab/scripts/ros2/sim2sim_ros2.py \
  --onnx artifacts/policies/v5_model_40000/exported/policy.onnx \
  --map unitree_mujoco_go2/scene_icra2024_sloped.xml \
  --lidar \
  --domain-id 42 \
  --publish-height-scan
```

Terminal 2, run teleop:

```bash
cd /home/nuri/Unitree_Go2
source /opt/ros/humble/setup.bash
export ROS_DOMAIN_ID=42

python3 unitree_rl_lab/scripts/ros2/teleop_cmd_vel.py \
  --domain-id 42 \
  --max-lin 0 \
  --max-strafe 0 \
  --max-yaw 0
```

Terminal 3, accumulate and save the map:

```bash
cd /home/nuri/Unitree_Go2
source /opt/ros/humble/setup.bash
export ROS_DOMAIN_ID=42

python3 unitree_rl_lab/scripts/ros2/teleop_map_accumulator.py \
  --domain-id 42 \
  --cloud-topic /utlidar/cloud \
  --odom-topic /Odometry \
  --out-topic /teleop_map \
  --output /home/nuri/Unitree_Go2/artifacts/slam_maps/teleop_map_latest.pcd
```

Terminal 4, view in RViz:

```bash
source /opt/ros/humble/setup.bash
export ROS_DOMAIN_ID=42
rviz2 -d /home/nuri/Unitree_Go2/go2_roughnav/rviz/teleop_map_debug.rviz
```

## ROS2 Workspace Setup For FAST-LIO2 And TRG

Create ROS2 workspaces from this repository:

```bash
export REPO=/home/nuri/Unitree_Go2

mkdir -p ~/go2_roughnav_ws/src
ln -sfn "$REPO/go2_roughnav" ~/go2_roughnav_ws/src/go2_roughnav

mkdir -p ~/go2_sim_ws/src
ln -sfn "$REPO/TRG-planner-1" ~/go2_sim_ws/src/TRG-planner-1
```

Build TRG core and the ROS2 TRG package:

```bash
source /opt/ros/humble/setup.bash

cd ~/go2_sim_ws/src/TRG-planner-1
cmake -B cpp/trg_planner/build -S cpp/trg_planner \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$HOME/go2_sim_ws/install/trg_planner_core
cmake --build cpp/trg_planner/build -j$(nproc)
cmake --install cpp/trg_planner/build

cd ~/go2_sim_ws
export CMAKE_PREFIX_PATH=$HOME/go2_sim_ws/install/trg_planner_core:${CMAKE_PREFIX_PATH:-}
colcon build --symlink-install \
  --base-paths src/TRG-planner-1/pipelines/ros2 \
  --cmake-args -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH
```

Build the Go2 rough navigation package:

```bash
source /opt/ros/humble/setup.bash
source ~/go2_sim_ws/install/setup.bash

cd ~/go2_roughnav_ws
colcon build --symlink-install --packages-select go2_roughnav
source install/setup.bash
```

FAST-LIO2 itself is expected in a separate workspace, for example:

```text
/fastlio_ws/src/FAST_LIO_ROS2
/fastlio_ws/install/setup.bash
```

The included `go2_roughnav` launch files expect that layout by default. If your FAST-LIO2 path is different, pass `fastlio_launch:=/your/path/mapping.launch.py`.

## FAST-LIO2 Only

Terminal 1, publish simulated LiDAR and IMU:

```bash
cd /home/nuri/Unitree_Go2
source /opt/ros/humble/setup.bash
export ROS_DOMAIN_ID=42

python3 unitree_rl_lab/scripts/ros2/sim2sim_ros2.py \
  --onnx artifacts/policies/v5_model_40000/exported/policy.onnx \
  --map unitree_mujoco_go2/scene_icra2024_sloped.xml \
  --lidar \
  --domain-id 42 \
  --no-fastlio-odom \
  --publish-height-scan
```

Terminal 2, launch FAST-LIO2:

```bash
source /opt/ros/humble/setup.bash
source /fastlio_ws/install/setup.bash
source ~/go2_roughnav_ws/install/setup.bash
export ROS_DOMAIN_ID=42

ros2 launch go2_roughnav 02_fastlio_only.launch.py \
  fastlio_launch:=/fastlio_ws/src/FAST_LIO_ROS2/launch/mapping.launch.py
```

Expected topics:

```bash
ros2 topic echo /Odometry --once
ros2 topic echo /cloud_registered --once
```

## TRG-Planner Only

Launch TRG with one of the packaged map configs:

```bash
source /opt/ros/humble/setup.bash
source ~/go2_sim_ws/install/setup.bash
source ~/go2_roughnav_ws/install/setup.bash
export ROS_DOMAIN_ID=42

ros2 launch go2_roughnav 03_trg_only.launch.py \
  trg_map:=icra2024_sloped_route_robot30
```

Useful TRG map configs include:

```text
icra2023_easy_route_robot30
icra2023_hard_route_robot30
icra2024_flat_route_robot30
icra2024_sloped_route_robot30
icros2025_obstacle_left_robot30
icros2025_obstacle_right_robot30
```

For RViz/debug maps, see:

```text
TRG-planner-1/pipelines/config/
TRG-planner-1/prebuilt_maps/
```

## Full Sim Pipeline: MuJoCo + FAST-LIO2 + TRG + RL

Terminal 1, sim2sim with LiDAR and V5 policy:

```bash
cd /home/nuri/Unitree_Go2
source /opt/ros/humble/setup.bash
export ROS_DOMAIN_ID=42

python3 unitree_rl_lab/scripts/ros2/sim2sim_ros2.py \
  --onnx artifacts/policies/v5_model_40000/exported/policy.onnx \
  --map unitree_mujoco_go2/scene_icra2024_sloped.xml \
  --lidar \
  --domain-id 42 \
  --no-fastlio-odom \
  --require-height-scan
```

Terminal 2, FAST-LIO2 + TRG + path follower + height scan + RViz:

```bash
source /opt/ros/humble/setup.bash
source /fastlio_ws/install/setup.bash
source ~/go2_sim_ws/install/setup.bash
source ~/go2_roughnav_ws/install/setup.bash
export ROS_DOMAIN_ID=42

ros2 launch go2_roughnav 05_full_go2_rl_pipeline.launch.py \
  launch_fastlio:=true \
  launch_trg:=true \
  launch_cmd:=true \
  launch_height_scan:=true \
  launch_health:=true \
  launch_rviz:=true \
  fastlio_config_file:=fastlio_mujoco.yaml \
  trg_map:=icra2024_sloped_route_robot30 \
  rviz_config:=/home/nuri/Unitree_Go2/go2_roughnav/rviz/isaac_debug.rviz
```

Terminal 3, optional manual teleop override:

```bash
cd /home/nuri/Unitree_Go2
source /opt/ros/humble/setup.bash
export ROS_DOMAIN_ID=42

python3 unitree_rl_lab/scripts/ros2/teleop_cmd_vel.py \
  --domain-id 42 \
  --max-lin 0 \
  --max-strafe 0 \
  --max-yaw 0
```

## V5 Policy Runtime Contract

The V5 policy input is:

```text
proprio_history(225) + height_scan(273) = 498
```

Required runtime inputs:

```text
/cmd_vel          geometry_msgs/msg/Twist
/rl/height_scan   std_msgs/msg/Float32MultiArray, length 273
Go2 lowstate      IMU, joint positions, joint velocities
```

`/cmd_vel` alone is not enough for V5. The policy also needs `/rl/height_scan` for stairs, gaps, and rough terrain. In simulation, `sim2sim_ros2.py --publish-height-scan` can generate this from MuJoCo raycasts. In the FAST-LIO2 pipeline, `height_scan_bridge` converts `/cloud_registered` and `/Odometry` into `/rl/height_scan`.

## Smoke Tests

Check that the ONNX export is valid:

```bash
python3 - <<'PY'
import onnx
p = "/home/nuri/Unitree_Go2/artifacts/policies/v5_model_40000/exported/policy.onnx"
m = onnx.load(p)
onnx.checker.check_model(m)
print("ONNX OK")
print("inputs:", [(i.name, [d.dim_value for d in i.type.tensor_type.shape.dim]) for i in m.graph.input])
print("outputs:", [(o.name, [d.dim_value for d in o.type.tensor_type.shape.dim]) for o in m.graph.output])
PY
```

Compile the local ROS2 Python scripts:

```bash
cd /home/nuri/Unitree_Go2/unitree_rl_lab
python3 -m py_compile \
  scripts/ros2/sim2sim_ros2.py \
  scripts/ros2/teleop_cmd_vel.py \
  scripts/ros2/teleop_map_accumulator.py \
  scripts/ros2/height_scan_bridge.py \
  scripts/ros2/trg_path_follower.py
```

Inspect ROS topics during a run:

```bash
ros2 topic list
ros2 topic hz /utlidar/cloud
ros2 topic hz /rl/height_scan
ros2 topic echo /cmd_vel --once
ros2 topic echo /Odometry --once
```

## Notes

- The packaged policy artifact is V5 40k, not the older V2/V3/V4 experiments.
- The saved teleop map artifact is in `artifacts/slam_maps/teleop_map_latest.pcd`.
- ICROS2025 MuJoCo scene keeps the normal MuJoCo plane and removes the extra custom mesh floor that was causing confusing visual/collision behavior.
- Use conservative command limits on real hardware. The unlimited teleop command is intended for simulation debugging only.
