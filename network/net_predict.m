function res = net_predict(net, im, opts)
    
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
    net.layers{end}.class = 1;
    res = vl_simplenn(net, im, [], [], 'mode', 'test');
    res = squeeze(gather(res(end-1).x));
    [~, res] = max(res);
end

