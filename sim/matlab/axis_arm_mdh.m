% =========================================================================
%  六轴机械臂 · 改进 D-H (Robotics Toolbox for MATLAB / Peter Corke)
%  MATLAB R2025b + RTB v10
%
%  ---------- 原脚本的 3 个问题 (为什么"该共轴的关节却错开") ----------
%  1) d 里的 36.5/2+60 写在了 alpha = -pi/2 那一行。
%     modified DH 中 d_i 沿"本行 alpha 旋转之后的 z 轴"; alpha=-90° 已经把 z 转到 +Y,
%     于是这 78.25 变成沿 Y 的横向偏移, 肩关节被推到 (0, 78.25, 0)。
%     基座竖直段必须放在第 1 行 (alpha = 0, z 仍然竖直)。
%  2) 小臂 250 写成了 a(4)。a 是"公垂线长度", 永远垂直于两根关节轴;
%     所以 J4 的轴线垂直于小臂(变成竖直), 与 J6 只能平行、无法共轴。
%     小臂要沿 J4 轴线, 必须写进 d(4)。
%  3) d(5) = 51.5 把腕心沿 J5 轴线又推出去 51.5 mm, 球腕被拆开;
%     J6 只是平行于 J4, 偏了 51.5 mm。
%     J4/J5/J6 交于腕心, 所以 d(5) = 0, 只保留法兰偏置 d(6)。
%
%  ---------- 改好之后 ----------
%     J1 竖直 ; J2/J3/J5 平行 (+Y) ; J4/J6 垂直于它们且共轴
%     臂展 = 300 + 250 + 51.5 = 601.5 mm
% =========================================================================
clc; clear; close all;

%% 1. 结构尺寸 (mm)  —— 就改这一块
d1 = 36.5/2 + 60;     % 基座 -> 肩      竖直段   (若用你另一版的数: 62/2)
a2 = 300;             % 大臂: 肩 -> 肘
d4 = 250;             % 小臂: 肘 -> 腕   (沿 J4 轴线)
d6 = 57/2 + 46/2;     % 腕心 -> 法兰     (沿 J6 轴线)

%% 2. 改进 D-H 参数
%  Link([theta, d, a, alpha], 'modified')
%  变换:  A_i = Rx(alpha_i)·Tx(a_i)·Rz(theta_i)·Tz(d_i)
%
%   i     a_{i-1}    alpha_{i-1}     d_i      说明
%   1        0           0          d1       基座偏航  轴线 +Z (竖直)
%   2        0        -pi/2          0       肩部俯仰  轴线 +Y
%   3       a2           0           0       肘部俯仰  轴线 +Y (与 J2 平行)
%   4        0         pi/2         d4       腕部滚转  轴线 +Z, 即沿小臂
%   5        0        -pi/2          0       腕部俯仰  轴线 +Y (与 J2/J3 平行)
%   6        0         pi/2         d6       末端滚转  轴线 +Z (与 J4 共轴)
%
%  一句话: a 只负责"错开", d 才负责"沿着某根轴线"。
%        想让两个关节共轴, 只能靠 d; 写成 a 一定差 90°。

qlim = deg2rad([-170 170;
                -120 120;
                -150 150;
                -180 180;
                -120 120;
                -180 180]);

L(1) = Link([0, d1,  0,   0    ], 'modified');
L(2) = Link([0,  0,  0,  -pi/2 ], 'modified');
L(3) = Link([0,  0, a2,   0    ], 'modified');
L(4) = Link([0, d4,  0,   pi/2 ], 'modified');
L(5) = Link([0,  0,  0,  -pi/2 ], 'modified');
L(6) = Link([0, d6,  0,   pi/2 ], 'modified');

for i = 1:6
    L(i).qlim = qlim(i,:);      % 关节限位
end

six_link = SerialLink(L, 'name', 'Six_Axis_Arm');
six_link.display;

%% 3. 自检: 直接把每根轴线算出来看 (改参数后跑一下就知道对不对)
T  = eye(4);
ax = zeros(3,6);                % 轴线方向 (基坐标系)
po = zeros(3,6);                % 关节坐标原点
for i = 1:6
    T = T * L(i).A(0).T;        % RTB v10 返回 se3, .T 取 4x4
    ax(:,i) = T(1:3,3);
    po(:,i) = T(1:3,4);
end

ang = @(u,v) acosd( min(1, max(-1, dot(u,v)/(norm(u)*norm(v)))) );

fprintf('关节轴线 (q = 0):\n');
for i = 1:6
    fprintf('  J%d  方向 [%6.2f %6.2f %6.2f]   原点 [%8.2f %8.2f %8.2f]\n', ...
            i, ax(:,i), po(:,i));
end

fprintf('\n几何关系:\n');
fprintf('  J2 ∥ J3 : %5.1f°   %s\n', ang(ax(:,2),ax(:,3)), ok(ang(ax(:,2),ax(:,3)) < 1e-6));
fprintf('  J2 ∥ J5 : %5.1f°   %s\n', ang(ax(:,2),ax(:,5)), ok(ang(ax(:,2),ax(:,5)) < 1e-6));
fprintf('  J3 ∥ J5 : %5.1f°   %s\n', ang(ax(:,3),ax(:,5)), ok(ang(ax(:,3),ax(:,5)) < 1e-6));
fprintf('  J4 ⊥ J5 : %5.1f°   %s\n', ang(ax(:,4),ax(:,5)), ok(abs(ang(ax(:,4),ax(:,5))-90) < 1e-6));
fprintf('  J6 ⊥ J5 : %5.1f°   %s\n', ang(ax(:,6),ax(:,5)), ok(abs(ang(ax(:,6),ax(:,5))-90) < 1e-6));
fprintf('  J4 ∥ J6 : %5.1f°   %s\n', ang(ax(:,4),ax(:,6)), ok(ang(ax(:,4),ax(:,6)) < 1e-6));
fprintf('  J1 ⊥ J2 : %5.1f°   %s\n', ang(ax(:,1),ax(:,2)), ok(abs(ang(ax(:,1),ax(:,2))-90) < 1e-6));

% 共轴判据: J6 原点到 J4 轴线所在直线的距离, 应为 0
v    = po(:,6) - po(:,4);
dJ46 = norm(v - dot(v, ax(:,4)) * ax(:,4));
fprintf('  J4/J6 轴线间距 = %.3f mm   %s\n', dJ46, ok(dJ46 < 1e-6));

fprintf('\n关节间距:\n');
fprintf('  肩 -> 肘   |J3-J2| = %6.1f mm\n', norm(po(:,3)-po(:,2)));
fprintf('  肘 -> 腕   |J4-J3| = %6.1f mm\n', norm(po(:,4)-po(:,3)));
fprintf('  腕 -> 法兰 |J6-J4| = %6.1f mm\n', norm(po(:,6)-po(:,4)));
fprintf('  基座高度            = %6.1f mm\n\n', po(3,1));

%% 4. 正运动学
q0     = [0 0 0 0 0 0];                    % 折叠零位
q_home = deg2rad([0, 0, 90, 0, 0, 0]);     % 水平伸直 (臂展 601.5)

fprintf('q = [0 0 0 0 0 0]   末端: [%.1f %.1f %.1f] mm\n', six_link.fkine(q0).t);
fprintf('q = [0 0 90 0 0 0]° 末端: [%.1f %.1f %.1f] mm\n\n', six_link.fkine(q_home).t);

T06 = six_link.fkine(q_home);              % se3 对象, disp 会排版成齐次矩阵
disp('T06 ='); disp(T06);

%% 5. 画图对比两个位形
ws = [-200 700 -550 550 -250 700];         % 显示范围 (mm)

figure('Name', '六轴机械臂 · 改进DH');
tiledlayout(1,2,'Padding','compact');
nexttile; six_link.plot(q0,     'workspace', ws, 'scale', 0.9, 'jointdiam', 1.3);
title('q = 0 (折叠零位)');
nexttile; six_link.plot(q_home, 'workspace', ws, 'scale', 0.9, 'jointdiam', 1.3);
title('q = [0 0 90 0 0 0]°  (臂展 601.5 mm)');

%% 6. 交互示教
%  teach 会往"当前坐标轴"里装面板, 而上面用了 tiledlayout, 所以这里单独开一个 figure
if ~batchStartupOptionUsed
    figure('Name','示教界面');
    six_link.teach(q_home);                % 拖动滑块看姿态
end

fprintf('完成。\n');

%% ---------------------- 局部函数 ----------------------
function s = ok(c)
    if c, s = '✓'; else, s = '✗'; end
end
