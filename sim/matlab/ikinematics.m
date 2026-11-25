
clc;
clear;
close all;

%% 1. Modified DH parameters

a = [0, 0, 300, 0, 0, 0];

alpha = [0, -pi/2, 0, pi/2, -pi/2, pi/2];

d = [36.5/2+60, 0, 0, 250, 0, 57/2+46/2];

theta = [0, 0, 0, 0, 0, 0];

%% 2. Create six revolute joints

for i = 1:6
    L(i) = Link([theta(i), d(i), a(i), alpha(i)], 'modified');
end

%% 3. Create robot

six_link = SerialLink(L, 'name', 'Six_Axis_Arm');

six_link.display;

%% 4. Set a known joint configuration for testing
% 这里的角度单位为度，转换成rad

q_ref = deg2rad([20, -30, 45, 15, 25, -10]);

%% 5. Use forward kinematics to generate a target pose

T_goal = six_link.fkine(q_ref);

disp('目标末端位姿 T_goal = ');
disp(T_goal);

%% 6. Inverse kinematics

% 设置数值迭代的初始关节角
q0 = deg2rad([10, -20, 35, 10, 20, 0]);

% 数值逆运动学求解
q_sol = six_link.ikine(T_goal, ...
    'q0', q0, ...
    'mask', [1 1 1 1 1 1], ...
    'ilimit', 1000, ...
    'tol', 1e-8);

%% 7. Output solution

disp('逆运动学求解结果（rad）：');
disp(q_sol);

disp('逆运动学求解结果（deg）：');
disp(rad2deg(q_sol));

%% 8. Verify inverse kinematics using forward kinematics

T_check = six_link.fkine(q_sol);

disp('逆解代回正运动学得到的末端位姿：');
disp(T_check);

%% 9. Display robot posture

figure;
six_link.plot(q_sol);
title('Six Axis Robot - Inverse Kinematics');

%%数值迭代求逆解Levenberg-Marquardt(LM)
