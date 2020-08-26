function g = gaussian2D(x, y, px, py, wx, wy)
% gaussian2D - 2D高斯函数
%
% input:
%   - x: m*n, 自变量
%   - y: m*n, 自变量
%   - px: scaler, 中心位置
%   - py: scaler, 中心位置
%   - wx: scaler, 宽度/方差
%   - wy: scaler, 宽度/方差
% output:
%   - g: m*n, 因变量
%

g = exp(-((x - px)/wx) .^2 - ((y - py)/wy) .^2);

end