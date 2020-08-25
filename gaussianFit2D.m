function [outStruct] = gaussianFit2D(x, y, z, same, peakNum, iterNum)
% gaussianFit2D - 对2D数据进行高斯拟合
%
% input:
%   - x: m*n, 自变量
%   - y: m*n, 自变量
%   - z: m*n, 因变量
%   - same: bool, x 方向和y 方向的方差是否相同, 1-相同, 0-不相同
%   - peakNum: int, 高斯核个数
%   - iterNum: int, 最高迭代次数
% output:
%   - outStruct: struct, 结果结构体
%

if ~exist('iterNum', 'var')
    iterNum = 100;
end
if ~exist('peakNum', 'var')
    peakNum = 1;
end
if ~exist('same', 'var')
    same = 1;
end

global HEIGHTS PXS PYS WXS WYS ERRORS INDEX
INDEX = 0;
HEIGHTS = zeros(iterNum, peakNum);
PXS = zeros(iterNum, peakNum);
PYS = zeros(iterNum, peakNum);
WXS = zeros(iterNum, peakNum);
WYS = zeros(iterNum, peakNum);
ERRORS = zeros(iterNum, 1);

% 优化参数
options = optimset('TolX',0.0001, 'Display','off', 'MaxFunEvals',iterNum);
if same
    startPoint = calcStartSame(x, y, peakNum);
    fminsearch(@(lambda)(fitgaussian2DSame(lambda, x, y, z)), startPoint, options);
else
    startPoint = calcStart(x, y, peakNum);
    fminsearch(@(lambda)(fitgaussian2D(lambda, x, y, z)), startPoint, options);
end

if INDEX+1 < iterNum
    HEIGHTS(INDEX+1:end, :) = [];
    PXS(INDEX+1:end, :) = [];
    PYS(INDEX+1:end, :) = [];
    WXS(INDEX+1:end, :) = [];
    WYS(INDEX+1:end, :) = [];
    ERRORS(INDEX+1:end, :) = [];
end

outStruct = struct();
outStruct.height = HEIGHTS;
outStruct.px = PXS;
outStruct.py = PYS;
outStruct.wx = WXS;
outStruct.wy = WYS;
outStruct.error = ERRORS;

end

function startPoint = calcStart(x, y, peakNum)
% calcStart - 计算初始位置, 在取值范围内等间隔取点
%
% input:
%   - x: m*n, 自变量
%   - y: m*n, 自变量
%   - peakNum: int, 高斯核个数
% output:
%   - startPoint: 1*(peakNum*4), 由(px, py, wx, xy)依次构成
%

ss = 4;

maxXVal = max(x(:));
minXVal = min(x(:));
rangeX = maxXVal - minXVal;
stepX = rangeX / (peakNum + 1);
px = (stepX : stepX : rangeX-stepX) + minXVal;
wx = rangeX / (3 * peakNum);
maxYVal = max(y(:));
minYVal = min(y(:));
rangeY = maxYVal - minYVal;
stepY = rangeY / (peakNum + 1);
py = (stepY : stepY : rangeY-stepY) + minYVal;
wy = rangeX / (3 * peakNum);
startPoint = zeros(peakNum*ss, 1);
startPoint(1:ss:end) = px;
startPoint(2:ss:end) = py;
startPoint(3:ss:end) = wx;
startPoint(4:ss:end) = wy;

end

function startPoint = calcStartSame(x, y, peakNum)
% calcStart - 计算初始位置, 在取值范围内等间隔取点
%
% input:
%   - x: m*n, 自变量
%   - y: m*n, 自变量
%   - peakNum: int, 高斯核个数
% output:
%   - startPoint: 1*(peakNum*3), 由(px, py, wxy)依次构成
%

ss = 3;

maxXVal = max(x(:));
minXVal = min(x(:));
rangeX = maxXVal - minXVal;
stepX = rangeX / (peakNum + 1);
px = (stepX : stepX : rangeX-stepX) + minXVal;
wxy = rangeX / (3 * peakNum);
maxYVal = max(y(:));
minYVal = min(y(:));
rangeY = maxYVal - minYVal;
stepY = rangeY / (peakNum + 1);
py = (stepY : stepY : rangeY-stepY) + minYVal;
startPoint = zeros(peakNum*ss, 1);
startPoint(1:ss:end) = px;
startPoint(2:ss:end) = py;
startPoint(3:ss:end) = wxy;

end

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

function err = fitgaussian2D(lambda, x, y, z)
% gaussianFit2D - 2D高斯拟合, x 和 y 方向的方差不同
%
% input:
%   - lambda: 1*(peakNum*4), 由(px, py, wx, xy)依次构成
%   - x: m*n, 自变量
%   - y: m*n, 自变量
%   - z: m*n, 因变量
% output:
%   - err: scaler, 误差
% docs:
%   - 使用最小二乘计算参数
%

step = 4;
A = zeros(numel(x), round(length(lambda)/step));
for j = 1:length(lambda)/step
    g = gaussian2D(x, y, lambda((j-1)*step+1), lambda((j-1)*step+2), lambda((j-1)*step+3), lambda(j*step));
    g = g(:);
    A(:,j) = g;
end

Z = z(:);
height = A \ Z;
px = lambda(1:step:end);
py = lambda(2:step:end);
wx = lambda(3:step:end);
wy = lambda(4:step:end);

z1 = A * height;
err = norm(z1 - Z);

% 更新参数
global HEIGHTS PXS PYS WXS WYS ERRORS INDEX
INDEX = INDEX + 1;
HEIGHTS(INDEX, :) = height';
PXS(INDEX, :) = px;
PYS(INDEX, :) = py;
WXS(INDEX, :) = wx;
WYS(INDEX, :) = wy;
ERRORS(INDEX) = err;

end

function err = fitgaussian2DSame(lambda, x, y, z)
% gaussianFit2D - 2D高斯拟合, x 和 y 方向的方差相同
%
% input:
%   - lambda: 1*(peakNum*3), 由(px, py, wxy)依次构成
%   - x: m*n, 自变量
%   - y: m*n, 自变量
%   - z: m*n, 因变量
% output:
%   - err: scaler, 误差
% docs:
%   - 使用最小二乘计算参数
%

step = 3;
A = zeros(numel(x), round(length(lambda)/step));
for j = 1:length(lambda)/step
    g = gaussian2D(x, y, lambda((j-1)*step+1), lambda((j-1)*step+2), lambda((j-1)*step+3), lambda(j*step));
    g = g(:);
    A(:,j) = g;
end

Z = z(:);
height = A \ Z;
px = lambda(1:step:end);
py = lambda(2:step:end);
wx = lambda(3:step:end);
wy = wx;

z1 = A * height;
err = norm(z1 - Z);

% 更新参数
global HEIGHTS PXS PYS WXS WYS ERRORS INDEX
INDEX = INDEX + 1;
HEIGHTS(INDEX, :) = height';
PXS(INDEX, :) = px;
PYS(INDEX, :) = py;
WXS(INDEX, :) = wx;
WYS(INDEX, :) = wy;
ERRORS(INDEX) = err;

end