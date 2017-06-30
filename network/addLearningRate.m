function net = addLearningRate(net)
    for i = 1:numel(net.layers)
        if strcmpi(net.layers{i}.type, 'conv')
            net.layers{i}.learningRate = [1 2];
        end
    end
end

