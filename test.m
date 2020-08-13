close all; clear; clc;

x= 0:5:500;
y= 100*exp(-((x-200)/120).^2)+50*exp(-((x-400)/60).^2)+5*randn(size(x));
gNum = 2;
gStr = gaussianFit(x,y,gNum);

% visualization processing
% visualizationProcess(x, y, gStr, 'final'); % 最终结果
visualizationProcess(x, y, gStr, 'process'); % 处理过程
