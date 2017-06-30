function state = initState(net, opts)
    
    % initialize with momentum 0
    for i = 1:numel(net.layers)
        for j = 1:numel(net.layers{i}.weights)
            state.momentum{i}{j} = 0 ;
        end
    end

    % move CNN  to GPU as needed
    if opts.useGPU >= 1
        net = vl_simplenn_move(net, 'gpu') ;
        for i = 1:numel(state.momentum)
            for j = 1:numel(state.momentum{i})
            state.momentum{i}{j} = gpuArray(state.momentum{i}{j}) ;
            end
        end
    end
end