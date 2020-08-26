function visualizationProcess2D(x, y, z, outStruct, result, step)
% visualizationProcess2D - 可视化2D处理过程
%
% input:
%   - x: m*n, 自变量
%   - y: m*n, 自变量
%   - z: m*n, 因变量
%   - result: string, final: 最终拟合结果; process: 处理过程
%   - step: int, 间隔
%

if ~exist('freq', 'var')
    step = 5;
end

[num, gNum] = size(outStruct.height);

if strcmpi(result, 'final')
    figure('NumberTitle', 'off', 'Name', 'Final Result of 2D Gaussian Fitting')
    T = tiledlayout(2,2);

    nexttile(1)
    mesh(z)

    G = 0;
    for i = 1:gNum
        height = outStruct.height(end, i);
        px = outStruct.px(end, i);
        py = outStruct.py(end, i);
        wx = outStruct.wx(end, i);
        wy = outStruct.wy(end, i);
        gi = height * gaussian2D(x, y, px, py, wx, wy);
        G = G + gi;
    end

    nexttile(2)
    mesh(G)
    
    nexttile(3)
    contour(z)
    title('原始数据')
    
    nexttile(4)
    contour(G)
    title('拟合数据')
    
    T.TileSpacing = 'compact';
    T.Padding = 'compact';
    
    set(gca, 'color', 'none');
    fig_rgb = getframe(gcf);
    fig_rgb = fig_rgb.cdata;
    alpha = ones(size(fig_rgb, 1), size(fig_rgb, 2));
    fig_gray = rgb2gray(fig_rgb);
    alpha(fig_gray==240) = 0;
    imwrite(fig_rgb, '拟合结果_2D.png', 'Alpha', alpha);

elseif strcmpi(result, 'process')
    figure('NumberTitle', 'off', 'Name', 'Process of 2D Gaussian Fitting')
    T = tiledlayout(2,2);

    err = outStruct.error;
    err_df = err(2:end) - err(1:end-1);
    err_df = round(err_df * 10000)/10000;
    idx = find(abs(err_df)<=3);
    if idx
        num = idx(1);
    end

    for frm = 1 : step : num
        nexttile(1)
        mesh(z)

        G = 0;
        for i = 1:gNum
            height = outStruct.height(frm, i);
            px = outStruct.px(frm, i);
            py = outStruct.py(frm, i);
            wx = outStruct.wx(frm, i);
            wy = outStruct.wy(frm, i);
            gi = height * gaussian2D(x, y, px, py, wx, wy);
            G = G + gi;
        end

        nexttile(2)
        mesh(G)
        
        nexttile(3)
        contour(z)
        title('原始数据')
        
        nexttile(4)
        contour(G)
        title('拟合数据')
        
        title(T, ['第 ', num2str(frm), ' 次迭代,', ' err = ', sprintf('%.3f', err(frm))]);
        T.TileSpacing = 'compact';
        T.Padding = 'compact';

        [A, map] = rgb2ind(frame2im(getframe(gcf)), 256);
        if frm == 1
            imwrite(A, map, '迭代过程_2D.gif', 'gif', 'Loopcount',inf, 'DelayTime',0.05);
        else
            imwrite(A, map, '迭代过程_2D.gif', 'gif', 'WriteMode','append', 'DelayTime',0.05);
        end
    end
else
    error('参数不正确, 必须为[final, process]');
end

end