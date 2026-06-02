# Workspace Consolidation Notes

Updated: 2026-06-02

This repository is the active Go2 workspace. Use `~/Projects/Unitree_Go2` as the single project root for IsaacLab training, MuJoCo sim2sim, ROS2 SLAM, TRG-planner, competition maps, and Unitree SDK material. `~/Unitree_Go2` may be kept as a compatibility symlink for older commands.

## Active Layout

| Path | Purpose |
| --- | --- |
| `training/isaac_lab/unitree_rl_lab` | IsaacLab + RSL-RL training backend and experiment configs |
| `simulation/mujoco/go2` | MuJoCo Go2 model, scenes, and generated competition map scenes |
| `ros2/go2_roughnav` | ROS2 package for MuJoCo bridge, FAST-LIO2, TRG glue, RViz, and path following |
| `planning/trg_planner` | TRG-planner source and ROS2 pipeline |
| `maps/competition` | ICRA2023, ICRA2024, and ICROS2025 map assets |
| `third_party/unitree_sdk2` | Unitree SDK2 source needed for future Sim2Real integration |
| `third_party/unitree_sdk2_python` | Unitree SDK2 Python bindings/source |
| `artifacts` | Deployable policies and saved SLAM map outputs |

## Integrated Source Folders

These local folders were reviewed and folded into the consolidated repository:

| Original local source | Consolidated target |
| --- | --- |
| `~/unitree_rl_lab` | `training/isaac_lab/unitree_rl_lab` |
| `~/unitree_mujoco/unitree_robots/go2` | `simulation/mujoco/go2` |
| `~/go2_roughnav_ws/src/go2_roughnav` | `ros2/go2_roughnav` |
| `~/go2_sim_ws/src/TRG-planner-1` | `planning/trg_planner` |
| `~/ICRA2023_Quadruped_Robot_Challenges` | `maps/competition/ICRA2023_Quadruped_Robot_Challenges` |
| `~/ICRA2024_Quadruped_Robot_Challenges` | `maps/competition/ICRA2024_Quadruped_Robot_Challenges` |
| `~/Downloads/ICROS2025_Quadruped_Robot_Challenges-main` | `maps/competition/ICROS2025_Quadruped_Robot_Challenges` |
| `~/unitree_sdk2` | `third_party/unitree_sdk2` |
| `~/unitree_sdk2_python` | `third_party/unitree_sdk2_python` |

## Deliberately Excluded

The following were not included in the GitHub workspace:

| Excluded item | Reason |
| --- | --- |
| Isaac/RSL-RL training logs | Large generated outputs, not needed to reproduce the code state |
| `build/`, `install/`, `log/`, `logs/` | Generated ROS/CMake artifacts |
| `~/unitree_sdk2_install` | Local install output, reproducible from `third_party/unitree_sdk2` |
| ICRA2024 `ieee-qrc-2024-device_code` | Old competition device code plus a duplicate SDK copy; current SDK source is kept in `third_party` |
| `~/unitree_rl_lab/unitree_ros` | Legacy ROS1/Gazebo material, not part of the current MuJoCo + ROS2 + SDK2 path |
| editor/cache/download artifacts | Machine-local state |

## Local Legacy Folders

After this repository is validated on the target desktop, older sibling folders in `~/` can be archived or removed. Do not remove them blindly while old terminals, Docker containers, or ROS workspaces still depend on their paths.

Recommended archive candidates:

- `~/unitree_mujoco`
- `~/go2_sim_ws`
- `~/go2_roughnav_ws`
- `~/ICRA2023_Quadruped_Robot_Challenges`
- `~/ICRA2024_Quadruped_Robot_Challenges`
- `~/unitree_sdk2`
- `~/unitree_sdk2_python`

Treat `~/unitree_rl_lab` as the last folder to archive because older Docker/IsaacLab commands may still mount it directly.
