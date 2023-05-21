% 目标函数：计算相关系数的绝对值
function obj = objective(x)
    A = [1.2;0.5;0.8;2.1];
    B = x;
    obj = abs(corr(A, B));  % 获取相关系数的绝对值
end