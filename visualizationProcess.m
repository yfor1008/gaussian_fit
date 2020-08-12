function visualizationProcess(x, y, outStruct)
% visualizationProcess - 可视化处理过程
%
% input:
%   - x: 1*n, 行向量, 自变量
%   - y: 1*n, 行向量, 因变量
%   - outStruct: struct, 拟合结果结构体
%

[~, gNum] = size(outStruct.height);
legend_cell = cell(gNum+2, 1);

figure(1)
subplot(211)
plot(x, y, 'ro')
legend_cell{1} = '原始数据';
hold on,
G = 0;
for i = 1:gNum
    height = outStruct.height(end, i);
    position = outStruct.position(end, i);
    width = outStruct.width(end, i);
    gi = height * exp(-((x-position)/width).^2);
    G = G + gi;
    plot(x, gi)
    legend_cell{i+1} = ['第 ', num2str(i) ' 个高斯'];
end

plot(x, G)
legend_cell{end} = '拟合结果';
legend(legend_cell)

subplot(212)
plot(outStruct.error)

end