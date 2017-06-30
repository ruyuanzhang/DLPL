function [net, state, loss] = net_train(net, state, im, labels, opts)
    im = single(im);
    if size(im, 3) == 1
        im = repmat(im, [1 1 3]);
    end
    
    if opts.substractAverage
        im = bsxfun(@minus, im, net.meta.normalization.averageImage);
    end
    
    if opts.useGPU
        im = gpuArray(im);
    end
    res = [];
    
    net.layers{end}.class = labels ;
    res = vl_simplenn(net, im, 1, res, 'mode', 'normal') ;
    loss = squeeze(gather(res(end).x));
    [net, res, state] = accumulateGradients(net, res, state, opts, numel(labels), []);   
end

