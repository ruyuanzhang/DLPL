function p = makeParams(p)
    
    p.poolMethod = 'avg';
    p.modelType = 'simplenn';
    p.useGPU = true;
    p.poolMethod = 'avg';
    p.substractAverage = true;
    p.nesterovUpdate = false;
    p.momentum = 0.9;


    if strcmpi(p.layerName, 'relu1')
        p.poolShape = [148 148];
        p.clsShape = [96 2];
        p.learningRate = 1e-3;
        p.weightDecay = 5e-4;
    elseif strcmpi(p.layerName, 'relu2')
        p.poolShape = [73 73];
        p.clsShape = [256 2];
        p.learningRate = 1e-3;
        p.weightDecay = 5e-4;
    elseif strcmpi(p.layerName, 'relu3')
        p.poolShape = [36 36];
        p.clsShape = [384 2];
        p.learningRate = 1e-3;
        p.weightDecay = 5e-4;
    elseif strcmpi(p.layerName, 'relu4')
        p.poolShape = [36 36];
        p.clsShape = [384 2];
        p.learningRate = 1e-3;
        p.weightDecay = 5e-4;
    elseif strcmpi(p.layerName, 'relu5')
        p.poolShape = [36 36];
        p.clsShape = [256 2];
        p.learningRate = 1e-3;
        p.weightDecay = 5e-4;
    elseif strcmpi(p.layerName, 'relu6')
        p.poolShape = [12 12];
        p.clsShape = [4096 2];
        p.learningRate = 1e-4;
        p.weightDecay = 5e-4;
    elseif strcmpi(p.layerName, 'relu7')
        p.poolShape = [12 12];
        p.clsShape = [4096 2];
        p.learningRate = 1e-3;
        p.weightDecay = 5e-4;
    end

end

