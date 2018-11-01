function [opts,E] = updatePolyPCAparams(y,E,A,x,s,X,opts,gs,gA)
switch lower(opts.SolverAlgorithm)
    case 'vgd'
        UpdateStepSize
        UpdateSaddleNoise
    case 'admm'
        UpdateStepSize
        UpdateSaddleNoise
        for k = 1:opts.params.maxDeg-1
            opts.ADMM.gamma{k} = opts.ADMM.gamma{k}-opts.ADMM.eta*opts.ADMM.sigma*(opts.ADMM.x{k}-opts.ADMM.x{k+1});
        end
    case 'power'
end

if opts.Flags.ThetaUpdate
    tau = max(10,100*exp((1-opts.iter)/100));
    opts.theta = [1 -1/exp(1/tau)];
end

opts.nmse_prev = opts.nmse_current;                     % update nmse
opts.nmse_current = 100*norm(E,'fro')/norm(y,'fro');    % estimate of nmse
opts.params.nmse_history(opts.iter) = opts.nmse_prev;
opts.explained_var = 100-100*norm(E,'fro').^2/norm(y,'fro').^2;
if opts.iter > 1
    opts.converged = convergence(opts);             % check if converged
end


opts.iter = opts.iter +1;                               % next iteration
if mod(opts.iter,100) == 0
    outStruct.x_init = x;
    mkdir('savedResults/')
    fname = [opts.pwd filesep 'savedResults' filesep 'estimates'];
    save(fname,'outStruct','opts');
end

E = (y-A*X);                                              % residual

nmse_history = opts.params.nmse_history(max(1,opts.iter-10):opts.iter-1);
if  sum(abs(diff(nmse_history))) < 1
    opts.lambdaA = .5*opts.lambdaA;
    opts.lambdaX = .5*opts.lambdaX;
    opts.lambda  = .5*opts.lambda;
end
% if opts.lambdaA*norm(A,'fro')^2 + opts.lambdaX*norm(x(1:opts.params.d,'fro'))^2 +...
%         opts.lambda*norm(s(1:opts.params.d,'fro'))^2 < .01*norm(E,'fro')^2
%    opts.lambdaA = 0;
%    opts.lambdaX = 0;
%    opts.lambda = 0;
% elseif  sum(abs(diff(nmse_history))) < 1
%     opts.lambdaA = .95*opts.lambdaA;
%     opts.lambdaX = .95*opts.lambdaX;
%     opts.lambda  = .95*opts.lambda;
% end


if opts.Minimax
    opts = updateMinimaxParams(opts,E);
end

end

