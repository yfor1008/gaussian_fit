function [outStruct] = gaussianFit2D(x, y, z, same, peakNum, iterNum)
% gaussianFit2D - 对2D数据进行高斯拟合
%
% input:
%   - x: m*n, 自变量
%   - y: m*n, 自变量
%   - z: m*n, 因变量
%   - same: int, 代表高斯核不同模式
%           0-高斯核中心不同, xy 方向方差不同;
%           1-高斯核中心不同, xy 方向方差相同;
%           2-高斯核中心相同, xy 方向方差相同;
%           3-高斯核中心相同, xy 方向方差不同;
%   - peakNum: int, 高斯核个数
%   - iterNum: int, 最高迭代次数
% output:
%   - outStruct: struct, 结果结构体
% docs:
%   same=2/3 时, 拟合结果存在问题!!!
%

if ~exist('iterNum', 'var')
    iterNum = 500;
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
startPoint = calcStart(x, y, peakNum, same);
fminsearch(@(lambda)(fitgaussian2D(lambda, x, y, z, peakNum, same)), startPoint, options);

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

function startPoint = calcStart(x, y, peakNum, same)
% calcStart - 计算初始位置, 迭代参数起始位置
%
% input:
%   - x: m*n, 自变量
%   - y: m*n, 自变量
%   - peakNum: int, 高斯核个数
%   - same: int, 代表高斯核不同模式
%           0-高斯核中心不同, xy 方向方差不同;
%           1-高斯核中心不同, xy 方向方差相同;
%           2-高斯核中心相同, xy 方向方差相同;
%           3-高斯核中心相同, xy 方向方差不同;
% output:
%   - startPoint: 迭代参数
%       same=0 时, output 大小为 1*(peakNum*4), [px,py,wx,wy,px,py,wx,wy, ...]
%       same=1 时, output 大小为 1*(peakNum*3), [px,py,wxy,px,py,wxy, ...]
%       same=2 时, output 大小为 1*(peakNum*1+2), [px,py,wxy,wxy, ...]
%       same=3 时, output 大小为 1*(peakNum*2+2), [px,py,wx,wy,wx,wy, ...]
%

maxXVal = max(x(:));
minXVal = min(x(:));
rangeX = maxXVal - minXVal;
stepX = rangeX / (peakNum + 1);
maxYVal = max(y(:));
minYVal = min(y(:));
rangeY = maxYVal - minYVal;
stepY = rangeY / (peakNum + 1);

if same == 0
    px = (stepX : stepX : rangeX-stepX) + minXVal;
    wx = rangeX / (3 * peakNum);
    py = (stepY : stepY : rangeY-stepY) + minYVal;
    wy = rangeY / (3 * peakNum);

    ss = 4;
    startPoint = zeros(peakNum*ss, 1);
    startPoint(1:ss:end) = px;
    startPoint(2:ss:end) = py;
    startPoint(3:ss:end) = wx;
    startPoint(4:ss:end) = wy;
elseif same == 1
    px = (stepX : stepX : rangeX-stepX) + minXVal;
    wxy = rangeX / (3 * peakNum);
    py = (stepY : stepY : rangeY-stepY) + minYVal;

    ss = 3;
    startPoint = zeros(peakNum*ss, 1);
    startPoint(1:ss:end) = px;
    startPoint(2:ss:end) = py;
    startPoint(3:ss:end) = wxy;
elseif same == 2
    px = (maxXVal + minXVal)/2;
    py = (maxYVal + minYVal)/2;
    wxy = rangeX / (3 * peakNum);

    ss = 1;
    startPoint = zeros(peakNum*ss+2, 1);
    startPoint(1) = px;
    startPoint(2) = py;
    startPoint(3:end) = wxy;
elseif same == 3
    px = (maxXVal + minXVal)/2;
    py = (maxYVal + minYVal)/2;
    wx = rangeX / (3 * peakNum);
    wy = rangeY / (3 * peakNum);

    ss = 2;
    startPoint = zeros(peakNum*ss+2, 1);
    startPoint(1) = px;
    startPoint(2) = py;
    startPoint(3:ss:end) = wx;
    startPoint(4:ss:end) = wy;
else
    error('参数错误!');
end

end

function err = fitgaussian2D(lambda, x, y, z, peakNum, same)
% gaussianFit2D - 2D高斯拟合, x 和 y 方向的方差不同
%
% input:
%   - lambda: 1*(peakNum*4), 由(px, py, wx, xy)依次构成
%   - x: m*n, 自变量
%   - y: m*n, 自变量
%   - z: m*n, 因变量
%   - peakNum: int, 高斯核个数
%   - same: int, 代表高斯核不同模式
%       same=0 时, lambda 大小为 1*(peakNum*4), [px,py,wx,wy,px,py,wx,wy, ...]
%       same=1 时, lambda 大小为 1*(peakNum*3), [px,py,wxy,px,py,wxy, ...]
%       same=2 时, lambda 大小为 1*(peakNum*1+2), [px,py,wxy,wxy, ...]
%       same=3 时, lambda 大小为 1*(peakNum*2+2), [px,py,wx,wy,wx,wy, ...]
% output:
%   - err: scaler, 误差
% docs:
%   - 使用最小二乘计算参数
%

if same == 0
    step = 4;
    px = lambda(1:step:end);
    py = lambda(2:step:end);
    wx = lambda(3:step:end);
    wy = lambda(4:step:end);
elseif same == 1
    step = 3;
    px = lambda(1:step:end);
    py = lambda(2:step:end);
    wx = lambda(3:step:end);
    wy = wx;
elseif same == 2
    step = 1;
    px = ones(1, peakNum) * lambda(1);
    py = ones(1, peakNum) * lambda(2);
    wx = lambda(3:step:end);
    wy = wx;
elseif same == 3
    step = 2;
    px = ones(1, peakNum) * lambda(1);
    py = ones(1, peakNum) * lambda(2);
    wx = lambda(3:step:end);
    wy = lambda(4:step:end);
else
    error('参数错误!');
end

A = zeros(numel(x), peakNum);
for j = 1:peakNum
    g = gaussian2D(x, y, px(j), py(j), wx(j), wy(j));
    g = g(:);
    A(:,j) = g;
end

Z = z(:);
height = A \ Z;

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