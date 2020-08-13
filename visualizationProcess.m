function visualizationProcess(x, y, outStruct, result, step)
% visualizationProcess - 可视化处理过程
%
% input:
%   - x: 1*n, 行向量, 自变量
%   - y: 1*n, 行向量, 因变量
%   - outStruct: struct, 拟合结果结构体
%   - result: string, final: 最终拟合结果; process: 处理过程
%   - step: int, 间隔
%

if ~exist('freq', 'var')
    step = 5;
end

[num, gNum] = size(outStruct.height);
legend_cell = cell(gNum+2, 1);

if strcmpi(result, 'final')
    plot(x, y, 'ro')
    axis([0, max(x), 0, max(y)*1.2])
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
    [A, map] = rgb2ind(frame2im(getframe(gcf)), 256);
    imwrite(A, map, '拟合结果.png');
elseif strcmpi(result, 'process')

    err = outStruct.error;
    err_df = err(2:end) - err(1:end-1);
    err_df = round(err_df * 10000)/10000;
    idx = find(err_df==0);
    if idx
        num = idx(1);
    end

    for frm = 1 : step : num
        subplot(211)
        plot(x, y, 'ro')
        axis([0, max(x), 0, max(y)*1.2])
        legend_cell{1} = '原始数据';
        hold on,
        G = 0;
        for i = 1:gNum
            height = outStruct.height(frm, i);
            position = outStruct.position(frm, i);
            width = outStruct.width(frm, i);
            gi = height * exp(-((x-position)/width).^2);
            G = G + gi;
            plot(x, gi)
            legend_cell{i+1} = ['第 ', num2str(i) ' 个高斯'];
        end
    
        plot(x, G)
        legend_cell{end} = '拟合结果';
        legend(legend_cell)
        hold off,
        
        subplot(212)
        % plot(outStruct.error(1:frm))
        semilogy(outStruct.error(1:frm))
        % xlabel('iter')
        % ylabel('error')
        
        suptitle(['第 ', num2str(frm), ' 次迭代']);
    
        [A, map] = rgb2ind(frame2im(getframe(gcf)), 256);
        if frm == 1
            imwrite(A, map, '迭代过程.gif', 'gif', 'Loopcount',inf, 'DelayTime',0.005);
        else
            imwrite(A, map, '迭代过程.gif', 'gif', 'WriteMode','append', 'DelayTime',0.005);
        end
    end
else
    error('参数不正确, 必须为[final, process]');
end

end