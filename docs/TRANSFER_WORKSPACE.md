# Workspace Transfer Notes

Updated: 2026-06-02

The target layout is:

```text
~/Projects/Unitree_Go2
~/Projects/IsaacLab
~/Projects/IsaacLab/omx_f_isaaclab
~/Projects/open_manipulator
~/Projects/ros2_ws
```

No compatibility symlinks are created. Keep editors, shells, Docker mounts, and scripts pointed at the real `~/Projects/...` paths.

## Restore From Local Bundle

From the extracted bundle directory:

```bash
./restore_workspace.sh
source ~/.bashrc
```

Then check:

```bash
go2repo
omxlab
omxsrc
```

## Restore From GitHub And External Sources

If the local bundle is unavailable, clone the main Go2 repository:

```bash
mkdir -p ~/Projects
git clone https://github.com/Kimz1xq/Unitree_Go2.git ~/Projects/Unitree_Go2
~/Projects/Unitree_Go2/scripts/install_workspace_env.sh
source ~/.bashrc
```

External source references captured from this desktop:

```text
IsaacLab origin: https://github.com/isaac-sim/IsaacLab.git
IsaacLab commit: 3e73d6dd79080fd7632488c061052a6edd52e230

open_manipulator origin: https://github.com/ROBOTIS-GIT/open_manipulator.git
open_manipulator commit: 86163c4fbc7d8aeee3cb05d5733cc589c51299ae
```

`omx_f_isaaclab` is a local IsaacLab experiment folder and is included in the transfer bundle under `Projects/IsaacLab/omx_f_isaaclab`.
