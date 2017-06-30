function net = addWeightDecay(net)
    
    for i = 1:numel(net.layers)
        if strcmpi(net.layers{i}.type, 'conv')
            net.layers{i}.weightDecay = [1 0];
        end
    end
end

