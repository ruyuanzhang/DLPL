function poolFunc = getPoolFunc(spatialLayouts, method, featMapSize, useGPU)
%GETPOOLFUNC 此处显示有关此函数的摘要
%   此处显示详细说明
    
    if numel(featMapSize) == 1
        featMapSize(2) = featMapSize(1);
    end

    if strcmpi(method, 'rand')
        return;
    end
    
    if strcmpi(method, 'avg') | strcmpi(method, 'max')
        for i = 1:numel(spatialLayouts)
            t = sscanf(spatialLayouts{i},'%dx%d') ;
            px = ceil(featMapSize(1) / t(1));
            py = ceil(featMapSize(2) / t(2));
            if t(1) == 1
                sx = 1; 
            else
                sx = floor((featMapSize(1) - px) / (t(1) - 1));
            end
            if t(2) == 1
                sy = 1; 
            else
                sy = floor((featMapSize(1) - py) / (t(2) - 1));
            end
            net{i}.layers{1} = struct('type', 'pool', ...
                                      'method', method, ...
                                      'pool', [px py], ...
                                      'stride', [sx sy], ...
                                      'pad', 0) ;
            net{i} = vl_simplenn_tidy(net{i});
            if useGPU, net{i} = vl_simplenn_move(net{i}, 'gpu'); end
        end
        poolFunc = @(x) fprop(net, x);
    end
end

function feat = fprop(net, x)
    feat = cell(numel(net), 1);
    for i = 1:numel(net)
        res = vl_simplenn(net{i}, x);
        res = res(end).x;
        feat{i} = reshape(res, size(res,1)*size(res,2)*size(res,3), size(res,4));
    end
    feat = gather(cat(1, feat{:})');
end
