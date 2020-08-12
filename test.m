close all; clear; clc;

x= 0:10:500;
y= 100*exp(-((x-200)/120).^2)+50*exp(-((x-400)/60).^2)+randn(size(x));
gNum = 2;
gStr = gaussianFit(x,y,gNum);

% % show
% legend_cell = cell(gNum+2, 1);
% plot(x, y, 'b.')
% legend_cell{1} = 'origin';
% hold on, 
% G = 0;
% for i = 1 : gNum
%     height = gStr.height(end, i);
%     position = gStr.position(end, i);
%     width = gStr.width(end, i);
%     gi = height * exp(-((x-position)/width).^2);
%     G = G + gi;
%     plot(x, gi)
%     legend_cell{i+1} = ['g\_', num2str(i)];
% end
% plot(x, G)
% legend_cell{end} = 'fit';
% legend(legend_cell)

% visualization processing
visualizationProcess(x, y, gStr)
