% clc;
% clear;
% close all;
% 
% a0 = 0;
% a1 = 20;
% d = 30;
% theta1 = 0;
% theta2 = 0;
% theta3 = 0;
% 
% L(1) = Link([0,a0,0,0], 'modified');
% L(2) = Link([0,d,0,-pi/2], 'modified');
% L(3) = Link([0,a1,0,pi/2], 'modified');
% 
% three_link = SerialLink([L(1), L(2), L(3)]);
% three_link.display;
% 
% three_link.teach;


clc;
clear;
close all;

% Modified DH parameters
a = [0, 0, 0, 0, 0, 0];
alpha = [0, -pi/2, 0, pi/2, -pi/2, pi/2];
d = [0, 62/2, 300, 250, 57/2+46/2, 57/2+46/2];
theta = [0, 0, 0, 0, 0, 0];

% Create six revolute joints using Modified DH
for i = 1:6
    L(i) = Link([theta(i), d(i), a(i), alpha(i)], 'modified');
end

% Create the six-axis robot
six_link = SerialLink(L, 'name', 'Six_Axis_Arm');

% Display robot information
six_link.display;

% Show interactive joint teaching interface
six_link.teach;
