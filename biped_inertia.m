
% torso 
m_torso = 2.0;
w_torso = 0.20;
d_torso = 0.15;
h_torso = 0.30;

Ix_torso = ((1/12)*m_torso)*(d_torso^2 + h_torso^2)
Iy_torso = ((1/12)*m_torso)*(w_torso^2 + h_torso^2)
Iz_torso = ((1/12)*m_torso)*(w_torso^2 + d_torso^2)

% thigh
m_thigh = 1.0;
w_thigh = 0.08;
d_thigh = 0.08;
h_thigh = 0.25;

Ix_thigh = ((1/12)*m_thigh)*(d_thigh^2 + h_thigh^2)
Iy_thigh = ((1/12)*m_thigh)*(w_thigh^2 + h_thigh^2)
Iz_thigh = ((1/12)*m_thigh)*(w_thigh^2 + d_thigh^2)


% Shin
m_shin = 0.8;
w_shin = 0.06;
d_shin = 0.06;
h_shin = 0.25;

Ix_shin = ((1/12)*m_shin)*(d_shin^2 + h_shin^2)
Iy_shin = ((1/12)*m_shin)*(w_shin^2 + h_shin^2)
Iz_shin = ((1/12)*m_shin)*(w_shin^2 + d_shin^2)

% Foot
m_foot = 0.4;
w_foot = 0.12;
d_foot = 0.20;
h_foot = 0.04;

Ix_foot = ((1/12)*m_foot)*(d_foot^2 + h_foot^2)
Iy_foot = ((1/12)*m_foot)*(w_foot^2 + h_foot^2)
Iz_foot = ((1/12)*m_foot)*(w_foot^2 + d_foot^2)

