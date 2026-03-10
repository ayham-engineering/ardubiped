# ardubiped

A 10-DOF biped robot simulation controlled via ArduPilot (ArduRover) in Gazebo Harmonic.

Each leg has Hip (Pitch + Roll), Knee (Pitch), and Ankle (Pitch + Roll) joints. 5 DOF per leg, 10 total. The robot is anchored to the world for joint testing.

[Read the full writeup on Substack](https://open.substack.com/pub/ayhamnotes/p/ardupilot-is-flight-control-software?r=4kv56c&utm_campaign=post&utm_medium=web&showWelcomeOnShare=true)

[Read the raw logs on Telegram](https://t.me/ayham_logs)

---

## Prerequisites

- Ubuntu 24.04 (or distrobox with Ubuntu 24.04)
- [Gazebo Harmonic](https://gazebosim.org/docs/harmonic/install)
- [ardupilot_gazebo plugin](https://github.com/ArduPilot/ardupilot_gazebo)
- [ArduPilot SITL](https://ardupilot.org/dev/docs/setting-up-sitl-on-linux.html)
- MAVProxy: `pip install mavproxy`

Or run the setup script which installs everything:
```bash
bash scripts/distrobox_setup.sh
```

---

## Run

**Terminal 1 — Gazebo:**
```bash
export GZ_SIM_SYSTEM_PLUGIN_PATH=/opt/ardupilot_gazebo/build
export GZ_SIM_RESOURCE_PATH=~/Projects/ardubiped/models:~/Projects/ardubiped/worlds
gz sim worlds/sim.sdf -r
```

**Terminal 2 — SITL:**
```bash
mkdir -p /tmp/sitl && cd /tmp/sitl
/opt/ardupilot/build/sitl/bin/ardurover \
    --model JSON --sim-address 127.0.0.1 \
    --sim-port-in 9003 --sim-port-out 9002 \
    --defaults ~/Projects/ardubiped/params/rover.parm \
    --home 0,0,0,0
```

**Terminal 3 — MAVProxy:**
```bash
mavproxy.py --master tcp:127.0.0.1:5760
```

---

## Control Joints

Once you see `MANUAL>` in MAVProxy:
```
arm throttle force
rc 1 1500    # right hip pitch
rc 2 1500    # right hip roll
rc 3 1500    # right knee pitch
rc 4 1500    # right ankle pitch
rc 5 1500    # right ankle roll
rc 6 1500    # left hip pitch
rc 7 1500    # left hip roll
rc 8 1500    # left knee pitch
rc 9 1500    # left ankle pitch
rc 10 1500   # left ankle roll
```

PWM range: 1000–2000. Neutral is ~1000 for most joints.
