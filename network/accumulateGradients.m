% -------------------------------------------------------------------------
function [net, res, state] = accumulateGradients(net, res, state, params, batchSize, parserv)
% -------------------------------------------------------------------------
for l=numel(net.layers):-1:1
  for j=numel(res(l).dzdw):-1:1
    parDer = res(l).dzdw{j}  ;

    if j == 3 && strcmp(net.layers{l}.type, 'bnorm')
      % special case for learning bnorm moments
      thisLR = net.layers{l}.learningRate(j) ;
      net.layers{l}.weights{j} = vl_taccum(...
        1 - thisLR, ...
        net.layers{l}.weights{j}, ...
        thisLR / batchSize, ...
        parDer) ;
    else
      % Standard gradient training.
      thisDecay = params.weightDecay * net.layers{l}.weightDecay(j) ;
      thisLR = params.learningRate * net.layers{l}.learningRate(j) ;

      if thisLR>0 || thisDecay>0
        % Normalize gradient and incorporate weight decay.
        parDer = vl_taccum(1/batchSize, parDer, ...
                           thisDecay, net.layers{l}.weights{j}) ;

        % Update momentum.
        state.momentum{l}{j} = vl_taccum(...
          params.momentum, state.momentum{l}{j}, ...
          -1, parDer) ;

        % Nesterov update (aka one step ahead).
        if params.nesterovUpdate
          delta = vl_taccum(...
            params.momentum, state.momentum{l}{j}, ...
            -1, parDer) ;
        else
          delta = state.momentum{l}{j} ;
        end

        % Update parameters.
        net.layers{l}.weights{j} = vl_taccum(...
          1, net.layers{l}.weights{j}, ...
          thisLR, delta) ;
      end
    end
  end
end