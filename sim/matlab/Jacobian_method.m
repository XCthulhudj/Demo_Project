function J = Jacobian_method(q, a, alpha, d)

%长度单位：mm
%使用弧度制rad

n = length(q);

o = zeros(3,n);
z = zeros(3,n);

T = eye(4);

for i = 1:n
    ca = cos(alpha(i));
    sa = sin(alpha(i));

    ct = cos(q(i));
    st = sin(q(i));

    T_fixed = [
        1  0   0  a(i);
        0  ca -sa  0;
        0  sa  ca  0;
        0  0   0   1;
    ];

    T_pre = T * T_fixed;

    o(:,i) = T_pre(1:3, 4);
    z(:,i) = T_pre(1:3, 3);

    A = [
        ct      -st     0       a(i);
        st*ca   ct*ca   -sa     -sa*d(i);
        st*sa   ct*sa   ca      ca*d(i);
        0       0       0       1
    ];

    T = T * A;
end

o_e = T(1:3,4);

J = zeros(6,n);

for i = 1:n
    J(1:3,i) = cross(z(:,i), o_e-o(:,i));
    J(4:6,i) = z(:,i);
end

end
