function model = loadCNNModel(modelPath, layerName, modelType)
%loadCNNModel loading a CNN model and removing extra layers
%   
%   Params 
%       'modelPath'
%           the modal path and name
%       'layerName' 
%           layerName used for features
%       'modelType'
%           modelType should be 'simple' or 'dag'
%       'useGPU'
%           gpu used or not
%
%   Return a CNN model and the extracted feature index
%   
%   Created by Lingxiao.Yang
%   Date 05/26/2016

%%
    if strcmpi(modelType, 'simplenn')
        model = load(modelPath);
        model = vl_simplenn_tidy(model);
        model.meta.normalization.averageImage = ...
            mean(mean(model.meta.normalization.averageImage, 1), 2);
        
        layer = find(cellfun(@(a) strcmp(a.name, layerName), model.layers) ==1 );
        model.layers(layer+1:end) = [];
        
        % removing layers to save GPU memory
        model.layers(layer+1:end) = [];
        model.layers{end}.precious = 1;
    elseif strcmpi(modelType, 'dagnn')
        model = dagnn.DagNN.loadobj(load(modelPath));
        startIndex = model.getVarIndex(layerName);
        endIndex = model.getVarIndex('prob')-1;
        for i = startIndex:endIndex
            lname{i-startIndex+1} = model.layers(i).name;
        end
        model.removeLayer(lname);
        model.mode = 'test';
    end
end

