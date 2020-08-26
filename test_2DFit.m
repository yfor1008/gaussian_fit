close all; clear; clc;

[x, y] = meshgrid(1:480, 1:480);
z = 100 * exp(-((x-200)/120).^2 - ((y-300)/120).^2) + 1 * randn(size(x));
% figure, mesh(z)

% fit
[outStruct] = gaussianFit2D(x, y, z, 1);
px = outStruct.px(end);
py = outStruct.py(end);
wx = outStruct.wx(end);
wy = outStruct.wy(end);
height = outStruct.height(end);
g = exp(-((x - px)/wx) .^2 - ((y - py)/wy) .^2);
% figure, mesh(g)


