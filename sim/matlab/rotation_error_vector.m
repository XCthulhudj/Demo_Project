
function e = rotation_error_vector(R)

% 将旋转矩阵转换成旋转向量
% 输入：3x3 旋转矩阵
% 输出：3x1 旋转误差向量，单位 rad

c = (trace(R)-1)/2;

% 防止浮点误差导致 acos 输入超出范围
c = max(-1,min(1,c));

theta = acos(c);

v = [
    R(3,2)-R(2,3);
    R(1,3)-R(3,1);
    R(2,1)-R(1,2)
];

if theta < 1e-8

    e = 0.5*v;

elseif abs(pi-theta) < 1e-5

    % 接近 180 度时，使用特征向量计算旋转轴
    [V,D] = eig(R);

    [~,idx] = min(abs(diag(D)-1));

    axis = real(V(:,idx));
    axis = axis/norm(axis);

    if norm(v) > 1e-8 && dot(axis,v) < 0
        axis = -axis;
    end

    e = theta*axis;

else

    e = theta/(2*sin(theta))*v;

end

end
