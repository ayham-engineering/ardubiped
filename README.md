# Ardubiped

A **10-DOF** biped robot simulation controlled via ArduPilot (ArduRover) in Gazebo Harmonic.

Each leg has Hip (Pitch + Roll), Knee (Pitch), and Ankle (Pitch + Roll) joints. 5 DOF per leg, 10 total. The robot is capable of standing and maintaining an **indefinite bipedal balance** using a custom 4-joint PD controller.

**[Read the full writeup on Substack](https://open.substack.com/pub/ayhamnotes/p/ardupilot-is-flight-control-software?r=4kv56c&utm_campaign=post&utm_medium=web&showWelcomeOnShare=true)**

**[Read the raw logs on Telegram](https://t.me/ayham_logs)**

---

## Architecture Decisions (GSoC 2026 Focus)

1. Firmware Selection: Why ArduRover instead of ArduCopter?
Many legged experiments default to ArduCopter because it has out-of-the-box 3D spatial awareness. However, legged robots are fundamentally ground vehicles. I chose ArduRover because I wanted to avoid the aerodynamics assumptions inside ArduCopter's motor mixing, even if EKF3 is slightly noisier. In addition, the project list for 2026 states: "Expected Outcome: A minimal humanoid 'vehicle type' running on ArduPilot with SITL support".


2. Low-Latency Joint Control: The `gz.transport13` Pipeline
Standard RC override channels via MAVLink was what I used at first but they introduce a latency ceiling. In earlier tests, sending high-frequency joint corrections over MAVLink hit a bottleneck, limiting the Proportional gain and causing crashes. To solve this, the current architecture separates Attitude Estimation from Actuation. The Python controller receives the EKF3 attitude via MAVLink UDP, but writes joint commands natively through `gz.transport13` publishers. This leads to not having any latency in the communication to the Gazebo `JointPositionController` plugins.

3. Kinematics and Leverage: 4-Joint Ground Interaction
Initial tests attempting to balance using only the hip joints failed. Only after synchronizing the hips with the ankle joints, the leg becomes a rigid lever against the ground. This combination of ArduRover EKF estimation and 4-joint Gazebo actuation achieved a perfectly stable bipedal balance.

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

**Terminal 1 - Gazebo:**
```bash
export GZ_SIM_SYSTEM_PLUGIN_PATH=/opt/ardupilot_gazebo/build
export GZ_SIM_RESOURCE_PATH=~/Projects/ardubiped/models:~/Projects/ardubiped/worlds
gz sim worlds/sim.sdf -r
```

**Terminal 2 - SITL:**
```bash
mkdir -p /tmp/sitl && cd /tmp/sitl
/opt/ardupilot/build/sitl/bin/ardurover \
  --model JSON --sim-address 127.0.0.1 \
  --sim-port-in 9003 --sim-port-out 9002 \
  --defaults ~/Projects/ardubiped/params/rover.parm \
  --home 0,0,0,0
```

**Terminal 3 - MAVProxy:**
```bash
mavproxy.py --master tcp:127.0.0.1:5760 --out udp:127.0.0.1:14551
```

**Terminal 4 - Balance Controller:**
Wait until Terminal 2 prints EKF3 IMU0 tilt alignment complete, then run:

```bash
python3 scripts/balance.py
```


---

## Manual Joint Control

If you want to manually test the joints movement individually without the script, you can use those commands once you see `MANUAL>` in MAVProxy:
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
