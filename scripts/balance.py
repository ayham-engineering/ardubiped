#!/usr/bin/env python3
from pymavlink import mavutil
from gz.transport13 import Node
from gz.msgs10.double_pb2 import Double
import time, math

mav = mavutil.mavlink_connection('udp:0.0.0.0:14551')
mav.wait_heartbeat()
print("Connected!")

print("Waiting for EKF stable...")
for _ in range(100):
    m = mav.recv_match(type='ATTITUDE', blocking=True, timeout=1.0)
    if m and abs(m.pitch) < 0.15:
        break
print("EKF stable — starting balance")

node = Node()
right_hip_pub = node.advertise('/right_hip_pitch/cmd', Double)
left_hip_pub  = node.advertise('/left_hip_pitch/cmd',  Double)
right_ankle_pub = node.advertise('/right_ankle_pitch/cmd', Double)
left_ankle_pub  = node.advertise('/left_ankle_pitch/cmd',  Double)
time.sleep(0.5)

Kp, Ki, Kd = 0.5, 0.0, 0.15
integral, last_error, last_time = 0.0, 0.0, time.time()

def send_joint(pub, angle):
    msg = Double()
    msg.data = float(angle)
    pub.publish(msg)

print("Balance controller running")
while True:
    m = mav.recv_match(type='ATTITUDE', blocking=True, timeout=1.0)
    if m:
        pitch = m.pitch
        now = time.time()
        dt = max(now - last_time, 0.01)
        error = pitch
        integral = max(-1.0, min(1.0, integral + error * dt))
        derivative = (error - last_error) / dt
        correction = max(-1.0, min(1.0,
                      Kp*error + Ki*integral + Kd*derivative))
        send_joint(right_hip_pub, -correction)
        send_joint(left_hip_pub,  -correction)
        send_joint(right_ankle_pub, -correction)
        send_joint(left_ankle_pub,  -correction)
        last_error, last_time = error, now
        print(f"Pitch: {math.degrees(pitch):>+6.1f}°  Correction: {correction:>+.4f}")
    time.sleep(0.025)