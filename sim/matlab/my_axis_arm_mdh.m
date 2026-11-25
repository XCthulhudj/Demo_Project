
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

%% 将 SE3 对象转换为普通 4×4 矩阵

if isa(T_goal, 'SE3')
    T_goal_mat = T_goal.T;
else
    T_goal_mat = T_goal;
end


%% 6. DLS Numerical Inverse Kinematics

% 初始关节角
q0 = deg2rad([10, -20, 35, 10, 20, 0]);

% 当前关节角，使用列向量
q = q0(:);

% DLS 阻尼系数
lambda = 1.0;

% 姿态误差权重，单位 mm/rad
% 用于统一位置误差和姿态误差的量纲
rot_scale = 100;

% 每次迭代允许的最大关节角增量
max_step = deg2rad(5);

% 收敛条件
tol_pos = 1e-3;       % 位置误差，单位 mm
tol_ori = 1e-5;       % 姿态误差，单位 rad

% 最大迭代次数
max_iter = 1000;

% 收敛标志
converged = false;

%% 7. Iteration

for k = 1:max_iter

    % 当前关节角对应的末端位姿
    T_current = six_link.fkine(q.');

    % 兼容不同版本的 Robotics Toolbox
    if isa(T_current, 'SE3')
        T_current = T_current.T;
    end

    % 提取当前位置和姿态
    p_current = T_current(1:3,4);
    R_current = T_current(1:3,1:3);

    p_goal = T_goal_mat(1:3,4);
    R_goal = T_goal_mat(1:3,1:3);

    %% 计算位置误差

    e_pos = p_goal - p_current;

    %% 计算姿态误差

    % 在基坐标系下计算旋转误差
    R_error = R_goal * R_current';

    e_ori = rotation_error_vector(R_error);

    %% 组合误差向量

    % 姿态误差乘以特征长度，统一量纲
    e = [
        e_pos;
        rot_scale * e_ori
    ];

    %% 判断是否收敛

    if norm(e_pos) < tol_pos && norm(e_ori) < tol_ori

        converged = true;
        break;

    end

    %% 计算雅可比矩阵

    J = Jacobian_method(q.', a, alpha, d);

    % 对雅可比矩阵进行相同的量纲缩放
    J_scaled = [
        J(1:3,:);
        rot_scale * J(4:6,:)
    ];

    %% DLS 求解关节角增量

    dq = J_scaled' * ...
        ((J_scaled * J_scaled' + ...
        lambda^2 * eye(6)) \ e);

    %% 限制每次迭代的最大关节角增量

    max_dq = max(abs(dq));

    if max_dq > max_step
        dq = dq * (max_step / max_dq);
    end

    %% 更新关节角

    q = q + dq;

end

%% 8. Output solution

q_sol = q.';

disp('DLS 逆运动学求解结果（rad）：');
disp(q_sol);

disp('DLS 逆运动学求解结果（deg）：');
disp(rad2deg(q_sol));

fprintf('迭代次数：%d\n', k);

if converged
    disp('逆运动学求解成功！');
else
    disp('达到最大迭代次数，尚未满足收敛条件！');
end

%% 9. Verify using forward kinematics

T_check = six_link.fkine(q_sol);

if isa(T_check, 'SE3')
    T_check = T_check.T;
end

disp('逆解代回正运动学得到的末端位姿：');
disp(T_check);

% 计算最终位置误差
pos_error = norm(T_goal_mat(1:3,4) - T_check(1:3,4));

% 计算最终姿态误差
R_final_error = T_goal_mat(1:3,1:3) * T_check(1:3,1:3)';

ori_error = rotation_error_vector(R_final_error);

fprintf('最终位置误差：%.8f mm\n', pos_error);

fprintf('最终姿态误差：%.8f deg\n', ...
    rad2deg(norm(ori_error)));

%% 10. Display robot posture

figure;
six_link.plot(q_sol);
title('Six Axis Robot - DLS Inverse Kinematics');

