#!/usr/bin/env python3
from gz.transport13 import Node
from gz.msgs10.double_pb2 import Double
import time

node = Node()
right_hip_pub  = node.advertise('/right_hip_pitch/cmd', Double)
left_hip_pub   = node.advertise('/left_hip_pitch/cmd',  Double)
right_knee_pub = node.advertise('/right_knee_pitch/cmd', Double)
left_knee_pub  = node.advertise('/left_knee_pitch/cmd',  Double)
right_roll_pub = node.advertise('/right_hip_roll/cmd', Double)
left_roll_pub  = node.advertise('/left_hip_roll/cmd',  Double)
time.sleep(0.3)

def send(pub, val):
    msg = Double()
    msg.data = float(val)
    pub.publish(msg)

print("Hammering standing pose for 5 seconds...")
t = time.time()
while time.time() - t < 20.0:
    send(right_hip_pub,  -0.10)
    send(left_hip_pub,   -0.10)
    send(right_knee_pub, -0.20)
    send(left_knee_pub,  -0.20)
    send(right_roll_pub, 0.0)
    send(left_roll_pub,  0.0)
    time.sleep(0.005)  # 200Hz — faster than physics
print("Done")