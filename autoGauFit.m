function outStruct = autoGauFit(x, y, iterNum)
% autoGauFit - 对数据自动进行高斯拟合
%
% input:
%   - x: 1*n, 行向量, 自变量
%   - y: 1*n, 行向量, 因变量
%   - iterNum: int, 最高迭代次数
% output:
%   - outStruct: struct, 结果结构体
%

if ~exist('iterNum', 'var')
    iterNum = 1000;
end

maxVal = max(y);
outStruct = gaussianFit(x, y, 1, iterNum);

peakNum = 2:20;
for i = peakNum
    tempStruct = gaussianFit(x, y, i, iterNum);
    height = tempStruct.height(end, :);
    error = tempStruct.error(end);
    if ~isempty(find(height < maxVal/10, 1))
        continue;
    else
        if error < outStruct.error
            outStruct = tempStruct;
        end
    end
end

end