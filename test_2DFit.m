close all; clear; clc;

[x, y] = meshgrid(1:480, 1:480);
z = 100 * exp(-((x-200)/120).^2 - ((y-300)/120).^2) + 1 * randn(size(x));
% figure, mesh(z)

% fit
gStr = gaussianFit2D(x, y, z, 0, 2, 1000);
% visualizationProcess2D(x, y, z, gStr, 'final'); % 最终结果
visualizationProcess2D(x, y, z, gStr, 'process'); % 处理过程
