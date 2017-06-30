function func = getForwardFunc(modelType, poolType)
%getForwardFunc 此处显示有关此函数的摘要
%   此处显示详细说明

%%
    if strcmpi(poolType, 'max')
        poolFunc = @(x) max(max(x, [], 1), [], 2);
    elseif strcmpi(poolType, 'avg')
        poolFunc = @(x) mean(mean(x, 1), 2);
    elseif strcmpi(poolType, 'identity')
        poolFunc = @(x) x;
    else
        error('Unsupport pool type used in full image setting');
    end
        
    if strcmpi(modelType, 'simplenn')
        func = @(x, y) simpleNNFunc(x, y, poolFunc);
    elseif strcmpi(modelType, 'dagnn') | strcmpi(modelType, 'fromSimpleNN')
        func = @(x, y) dagNNFunc(x, y, poolFunc);
    end
    

end


function res = simpleNNFunc(model, I, poolFunc)
    res = vl_simplenn(model, I);
    res = squeeze(poolFunc(gather(res(end).x)));
end

function res = dagNNFunc(model, I, poolFunc)
    model.eval({'data', I});
    res = model.vars(end).value ;
    res = squeeze(gather(poolFunc(res)));
end

