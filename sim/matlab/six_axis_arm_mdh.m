%% ========================================================================
%  六轴机械臂 · 改进 D-H (MDH / Craig) 建模、正逆运动学与工作空间
%  MATLAB R2025b + Robotics System Toolbox
%
%  结构约定
%     J1 : 基座偏航, 轴线竖直
%     J2 : 肩部俯仰   ┐
%     J3 : 肘部俯仰   ├ 三轴互相平行
%     J5 : 腕部俯仰   ┘
%     J4 : 腕部滚转   ┐ 垂直于 J2/J3/J5
%     J6 : 末端滚转   ┘ 与 J4 共轴 (仅在 q5 = 0 时严格共线)
%
%  尺寸 (mm), 括号内为 MDH 参数出现的位置
%     J1 → J2 : 50     竖直段        (d1)
%     J2 → J3 : 300    大臂          (a2)
%     J3 → J4 : 250    小臂          (d4, 沿 J4 轴线 = 小臂方向)
%     J4 → 法兰: 50    腕段          (d6)
%     水平臂展 = 300 + 250 + 50 = 600
%
%  说明
%    · 采用 Craig 的改进 D-H:  T(i-1,i) = Rx(alpha(i-1))·Tx(a(i-1))·Rz(theta_i)·Tz(d_i)
%    · 表中第 i 行对应关节 i, 列顺序 [a(i-1), alpha(i-1), d(i), theta偏移]
%    · 长度单位统一为 mm, 工具箱不关心量纲, 绘图坐标同样是 mm
%    · "其余段 50 mm" 按两段处理: 基座竖直段 50 + 腕部到法兰 50;
%      若只需要其中一段, 把 L.base 或 L.tool 置 0 即可, 表格无需任何改动
%% ========================================================================
clear; clc; close all;

assert(~isempty(ver('robotics')), '本脚本需要 Robotics System Toolbox。');

%% ------------------------- 1. 尺寸参数 (mm) -----------------------------
L.base  = 50;     % J1(基座)  -> J2(肩)     竖直段
L.upper = 300;    % J2(肩)    -> J3(肘)     大臂
L.fore  = 250;    % J3(肘)    -> J4(腕)     小臂
L.tool  = 50;     % 腕心(J4/J5/J6 交点) -> 法兰

span = L.upper + L.fore + L.tool;          % 水平臂展
if abs(span - 600) > 1e-9
    warning('当前水平臂展 %.0f mm, 与需求的 600 mm 不一致', span);
end
fprintf('水平臂展: %.0f mm  (%g + %g + %g)\n\n', span, L.upper, L.fore, L.tool);

%% ------------------------- 2. 改进 D-H 参数表 --------------------------
%  行 = 关节, 列 = [a_{i-1}, alpha_{i-1}, d_i, theta偏移]
mdh = [        0,        0,  L.base,  0;    % J1  基座偏航   (竖直)
               0,     pi/2,       0,  0;    % J2  肩部俯仰   (-Y 轴)
        L.upper,        0,       0,  0;    % J3  肘部俯仰   (与 J2 平行)
               0,     pi/2,  L.fore,  0;    % J4  腕部滚转   (沿小臂, 与原 J2 垂直)
               0,    -pi/2,       0,  0;    % J5  腕部俯仰   (与 J2/J3 平行)
               0,     pi/2,  L.tool,  0];   % J6  末端滚转   (与 J4 共轴)

dhTab = table((1:6)', string({'J1','J2','J3','J4','J5','J6'})', ...
    mdh(:,1), rad2deg(mdh(:,2)), mdh(:,3), ...
    'VariableNames', {'i','Joint','a_im1_mm','alpha_im1_deg','d_i_mm'});
disp('改进 D-H 参数表:'); disp(dhTab);

%% ------------------------- 3. 构建 rigidBodyTree -----------------------
%  R2025b 中 rigidBodyTree.Base 为只读, 因此基座高度直接由表中 d1 承担。
robot = rigidBodyTree('DataFormat', 'column', 'MaxNumBodies', 10);

qlim = deg2rad([-170  170;      % J1
                -120  120;      % J2
                -150  150;      % J3
                -180  180;      % J4
                -120  120;      % J5
                -180  180]);    % J6

for i = 1:6
    body = rigidBody(sprintf('link%d', i));
    jnt  = rigidBodyJoint(sprintf('joint%d', i), 'revolute');
    setFixedTransform(jnt, [mdh(i,1:3), 0], 'mdh');   % [a alpha d theta], theta 由关节变量给出
    jnt.PositionLimits = qlim(i,:);
    body.Joint = jnt;
    addLinkVisuals(body, i, L);                        % 只影响显示, 不影响运动学
    if i == 1
        addBody(robot, body, 'base');
    else
        addBody(robot, body, sprintf('link%d', i-1));
    end
end

qZero = zeros(6,1);
qHome = deg2rad([0; 0; 90; 0; 0; 0]);      % 水平伸直姿态, 末端到达 600 mm

%% ------------------------- 4. 正运动学 (自实现 + 与工具箱对拍) ---------
T_robot = getTransform(robot, qHome, 'link6');
T_mine  = fkMDH(mdh, qHome);
fprintf('自实现 MDH 正解 与 工具箱 getTransform 的差值: %.3e\n', norm(T_robot - T_mine));
fprintf('home 姿态末端位置: [%.1f  %.1f  %.1f] mm\n\n', T_mine(1:3,4));

%% ------------------------- 5. 结构约束自检 -----------------------------
[~, Tall] = fkMDH(mdh, qZero);
zax  = squeeze(Tall(1:3,3,:));      % 3x6, 第 i 列 = 关节 i 的轴线方向
porg = squeeze(Tall(1:3,4,:));      % 3x6, 第 i 列 = 关节 i 的坐标原点

ang = @(u,v) acosd( min(1, max(-1, dot(u,v)/(norm(u)*norm(v)))) );

fprintf('关节轴几何关系 (q = 0):\n');
fprintf('  J2 ∥ J3 : %6.1f°%s\n', ang(zax(:,2),zax(:,3)), tick(ang(zax(:,2),zax(:,3)) < 1e-6));
fprintf('  J2 ∥ J5 : %6.1f°%s\n', ang(zax(:,2),zax(:,5)), tick(ang(zax(:,2),zax(:,5)) < 1e-6));
fprintf('  J3 ∥ J5 : %6.1f°%s\n', ang(zax(:,3),zax(:,5)), tick(ang(zax(:,3),zax(:,5)) < 1e-6));
fprintf('  J4 ⊥ J5 : %6.1f°%s\n', ang(zax(:,4),zax(:,5)), tick(abs(ang(zax(:,4),zax(:,5)) - 90) < 1e-6));
fprintf('  J6 ⊥ J5 : %6.1f°%s\n', ang(zax(:,6),zax(:,5)), tick(abs(ang(zax(:,6),zax(:,5)) - 90) < 1e-6));
fprintf('  J4 ∥ J6 : %6.1f°%s\n', ang(zax(:,4),zax(:,6)), tick(ang(zax(:,4),zax(:,6)) < 1e-6));
fprintf('  J1 ⊥ J2 : %6.1f°%s\n', ang(zax(:,1),zax(:,2)), tick(abs(ang(zax(:,1),zax(:,2)) - 90) < 1e-6));
fprintf('  J4、J6 轴线间距 : %.2f mm  (q5 = 0 时共轴)%s\n', ...
        lindist(porg(:,4), zax(:,4), porg(:,6), zax(:,6)), ...
        tick(lindist(porg(:,4), zax(:,4), porg(:,6), zax(:,6)) < 1e-6));

fprintf('\n关节电机间距 (q = 0):\n');
fprintf('  |J3 - J2| = %6.1f mm   (肩 → 肘)\n', norm(porg(:,3) - porg(:,2)));
fprintf('  |J4 - J3| = %6.1f mm   (肘 → 腕)\n', norm(porg(:,4) - porg(:,3)));
fprintf('  |J6 - J4| = %6.1f mm   (腕心 → 法兰)\n', norm(porg(:,6) - porg(:,4)));
fprintf('  基座高度  = %6.1f mm   (J1 → J2)\n\n', porg(3,1));

%% ------------------------- 6. 臂展 / 工作空间 --------------------------
N  = 12000;
rng(0);                                   % 结果可复现
P  = zeros(3, N);
for k = 1:N
    q = randomConfiguration(robot);
    T = fkMDH(mdh, q);
    P(:,k) = T(1:3,4);
end

shoulder = porg(:,2);                     % 肩点 (0,0,50)
reach3D  = max(vecnorm(P - shoulder, 2, 1));
reachH   = max(hypot(P(1,:), P(2,:)));    % 水平臂展 (绕 J1 轴线)

fprintf('工作空间抽样 (%d 组随机位形):\n', N);
fprintf('  末端到肩点最大距离 : %6.1f mm  (理论值 %.0f mm)\n', reach3D, span);
fprintf('  水平最大臂展       : %6.1f mm  (理论值 %.0f mm)\n', reachH, span);
fprintf('  伸直位形臂展       : %6.1f mm  (q = [0 0 90 0 0 0]°)\n\n', ...
        hypot(T_mine(1,4), T_mine(2,4)));

%% ------------------------- 7. 可视化 -----------------------------------
% 7.1 零位与工作姿态
figure('Name','MDH 模型','Position',[80 80 1100 580]);
tiledlayout(1,2,'Padding','compact');
nexttile; show(robot, qZero, 'Frames','on','PreservePlot',false);
title('q = 0 (折叠零位)'); finishAxes();
nexttile; show(robot, qHome, 'Frames','on','PreservePlot',false);
title('q = [0 0 90 0 0 0]° (水平伸直, 臂展 600 mm)'); finishAxes();

% 7.2 工作空间点云 + 理论臂展球
figure('Name','工作空间','Position',[120 120 900 760]);
scatter3(P(1,:), P(2,:), P(3,:), 4, P(3,:), 'filled', ...
         'MarkerFaceAlpha',0.30, 'MarkerEdgeAlpha',0.10);
hold on;
% 三个大圆示意"以肩点为心、半径 = 臂展"的球面 (可达工作空间的理论上界)
th = linspace(0, 2*pi, 240);
c  = [0.50 0.60 0.95];
plot3(shoulder(1) + span*cos(th), shoulder(2) + span*sin(th), ...
      shoulder(3)*ones(size(th)), 'Color',c, 'LineWidth',1.2);      % xy 平面
plot3(shoulder(1) + span*cos(th), shoulder(2)*ones(size(th)), ...
      shoulder(3) + span*sin(th), 'Color',c, 'LineWidth',1.2);      % xz 平面
plot3(shoulder(1)*ones(size(th)), shoulder(2) + span*sin(th), ...
      shoulder(3) + span*cos(th), 'Color',c, 'LineWidth',1.2);      % yz 平面
plot3(shoulder(1), shoulder(2), shoulder(3), 'k.', 'MarkerSize',16);
axis equal; grid on; box on; view(35, 22);
title(sprintf('工作空间点云  (%d 组随机位形);  蓝色大圆 = 以肩点为心、半径 %.0f mm 的臂展上界', N, span));
xlabel('x / mm'); ylabel('y / mm'); zlabel('z / mm');

% 7.3 四个典型姿态
figure('Name','典型姿态','Position',[160 160 1000 760]);
tiledlayout(2,2,'Padding','compact');
poses = {deg2rad([  0;   0;   0;   0;   0;   0]), 'q = 0 (折叠)'
         deg2rad([  0;   0;  90;   0;   0;   0]), 'q 水平伸直 (末端 600 mm)'
         deg2rad([ 45; -30;  60;  30; -45;  60]), 'q 一般作业位形'
         deg2rad([ 90;   0;  90;   0;   0;   0]), 'q J1 转 90°'};
for i = 1:4
    nexttile;
    show(robot, poses{i,1}, 'Frames','off','PreservePlot',false);
    title(poses{i,2}); finishAxes();
end

%% ------------------------- 8. 逆运动学演示 -----------------------------
qTgt  = deg2rad([30; -20; 55; 15; -40; 70]);          % 目标位形
Ttgt  = fkMDH(mdh, qTgt);
ptgt  = Ttgt(1:3,4);

ik     = inverseKinematics('RigidBodyTree', robot, 'SolverAlgorithm', 'LevenbergMarquardt');
seed   = deg2rad([10; 10; 10; 10; 10; 10]);
[qSol, info] = ik('link6', Ttgt, ones(1,6), seed);

Tsol   = fkMDH(mdh, qSol);
posErr = norm(Tsol(1:3,4) - ptgt);
rotErr = acosd( min(1, max(-1, (trace(Tsol(1:3,1:3)' * Ttgt(1:3,1:3)) - 1) / 2)) );

fprintf('逆运动学 (目标末端 [%.1f %.1f %.1f] mm):\n', ptgt);
fprintf('  求解状态 : %s\n', info.Status);
fprintf('  位置误差 : %.4f mm\n', posErr);
fprintf('  姿态误差 : %.4f°\n', rotErr);
fprintf('  关节解 (°): [%s]\n', num2str(rad2deg(qSol(:))', '%7.1f'));
fprintf('  目标   (°): [%s]\n\n', num2str(rad2deg(qTgt(:))', '%7.1f'));

figure('Name','逆运动学结果','Position',[200 200 760 640]);
show(robot, qSol, 'Frames','on','PreservePlot',false);
title(sprintf('逆解结果: 位置误差 %.4f mm, 姿态误差 %.4f°', posErr, rotErr));
finishAxes();

%% ------------------------- 9. 交互式滑块 -------------------------------
if ~batchStartupOptionUsed
    guiDemo(robot, qHome);
end

fprintf('完成。\n');

%% ======================= 局部函数 =====================================
function T = mdhT(a, alpha, d, theta)
% 改进 D-H 单连杆变换: Rx(alpha)·Tx(a)·Rz(theta)·Tz(d)
    ca = cos(alpha); sa = sin(alpha);
    ct = cos(theta); st = sin(theta);
    T = [ ct,     -st,      0,      a;
          st*ca,   ct*ca,   -sa,   -d*sa;
          st*sa,   ct*sa,    ca,    d*ca;
          0,        0,        0,      1 ];
end

function [T, Tall] = fkMDH(mdh, q)
% 改进 D-H 正运动学, 返回末端位姿 T 与每帧位姿 Tall(4x4xn)
    n   = size(mdh,1);
    T   = eye(4);
    Tall = zeros(4,4,n);
    for i = 1:n
        T = T * mdhT(mdh(i,1), mdh(i,2), mdh(i,3), q(i) + mdh(i,4));
        Tall(:,:,i) = T;
    end
end

function s = tick(ok)
% 控制台打勾
    if ok, s = '  ✓'; else, s = '  ✗'; end
end

function addLinkVisuals(body, i, L)
% 给连杆挂上简单几何体 (仅为显示效果, 不参与运动学)
% 各连杆坐标系: z 轴 = 该关节的轴线, 小臂沿连杆 3 的 -y, 腕段沿连杆 4/5/6 的 +z
    steel  = [0.78 0.80 0.84];      % 结构件
    accent = [0.93 0.60 0.16];      % 关节电机
    switch i
        case 1  % 基座立柱: z = 0 在肩部高度, 立柱向下延伸 L.base
            addVisual(body, 'Cylinder', [90, L.base], ...
                      trvec2tform([0 0 -L.base/2]), FaceColor = steel);
            addVisual(body, 'Cylinder', [64, 30], ...
                      trvec2tform([0 0 8]), FaceColor = accent);
        case 2  % 大臂: 沿 +x 方向, 长 L.upper
            addVisual(body, 'Cylinder', [58, 96], ...
                      trvec2tform([0 0 0]), FaceColor = accent);
            T = axang2tform([0 1 0 pi/2]); T(1:3,4) = [L.upper/2, 0, 0];
            addVisual(body, 'Capsule', [30, L.upper], T, FaceColor = steel);
        case 3  % 小臂: 沿 -y 方向, 长 L.fore
            addVisual(body, 'Cylinder', [50, 86], ...
                      trvec2tform([0 0 0]), FaceColor = accent);
            T = axang2tform([1 0 0 pi/2]); T(1:3,4) = [0, -L.fore/2, 0];
            addVisual(body, 'Capsule', [26, L.fore], T, FaceColor = steel);
        case 4  % 腕部滚转筒: 沿 +z 指向法兰
            addVisual(body, 'Cylinder', [44, 46], ...
                      trvec2tform([0 0 23]), FaceColor = steel);
        case 5  % 腕部俯仰叉: 沿 z (即 J5 轴线)
            addVisual(body, 'Cylinder', [40, 92], ...
                      trvec2tform([0 0 0]), FaceColor = accent);
        case 6  % 法兰盘
            addVisual(body, 'Cylinder', [46, 14], ...
                      trvec2tform([0 0 0]), FaceColor = steel);
    end
end

function finishAxes()
% 统一各姿态子图的显示风格 (等比例、自动范围)
    grid on; box on; daspect([1 1 1]); view(38, 26);
end

function d = lindist(p1, d1, p2, d2)
% 两条轴线之间的最短距离 (平行/共线时也能正确返回)
    c = cross(d1, d2);
    if norm(c) < 1e-9                       % 平行或共线: 点到直线距离
        v = p2 - p1;
        d = norm(v - dot(v, d1) * d1);
    else                                    % 异面: 公垂线方向投影
        d = abs(dot(p2 - p1, c / norm(c)));
    end
end

function guiDemo(robot, q0)
% 六自由度滑块演示
    f = figure('Name','六轴机械臂 · 滑块演示','Position',[60 60 1080 700]);
    ax = axes('Parent', f, 'Position', [0.32 0.06 0.65 0.88]);
    names = {'J1 基座','J2 肩','J3 肘','J4 腕滚转','J5 腕俯仰','J6 末端'};
    sl = gobjects(6,1); tx = gobjects(6,1);
    for i = 1:6
        y = 0.88 - (i-1)*0.14;
        uicontrol(f,'Style','text','String',names{i},'Units','normalized', ...
                  'Position',[0.02 y+0.045 0.12 0.03],'HorizontalAlignment','left');
        sl(i) = uicontrol(f,'Style','slider','Min',-180,'Max',180, ...
                  'Value',rad2deg(q0(i)),'Units','normalized', ...
                  'Position',[0.02 y 0.20 0.035],'Callback',@(~,~) refresh());
        tx(i) = uicontrol(f,'Style','text','String','','Units','normalized', ...
                  'Position',[0.23 y 0.07 0.03]);
    end
    refresh();

    function refresh()
        v = cell2mat(get(sl,'Value'));
        for k = 1:6
            set(tx(k),'String',sprintf('%+.0f°', v(k)));
        end
        show(robot, deg2rad(v), 'Parent', ax, 'PreservePlot', false, ...
             'Frames','off', 'FastUpdate', true);
        title(ax, '拖动滑块改变关节角');
        xlim(ax,[-800 800]); ylim(ax,[-800 800]); zlim(ax,[-500 900]);
        daspect(ax,[1 1 1]); grid(ax,'on');
    end
end
