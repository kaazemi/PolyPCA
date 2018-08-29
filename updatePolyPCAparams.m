function [etaS,saddleSigma,lambda,theta,nmse_prev,converged,iter] = updatePolyPCAparams(y,E,x,opts)
etaS = opts.etaS;
saddleSigma = opts.saddleSigma;
lambda = opts.lambda;
theta = opts.theta;
nmse_prev = opts.nmse_prev;
converged = opts.converged;
iter = opts.iter;
    
    if opts.nmse_current > opts.nmse_prev                     % update the step size with a momentum for better convergence
        etaS = 0.95*opts.etaS;
        saddleSigma = 0.9*opts.saddleSigma;
%         etaS = opts.etaS*opts.iter/(opts.iter+1);
    else
        if opts.nmse_current > .95*opts.nmse_prev
            saddleSigma = 1.1*opts.saddleSigma;
        else
            saddleSigma = 0.9*opts.saddleSigma;
        end
%         etaS = 1.01*opts.etaS;
    end
    if opts.nmse_current < 10                                  % if error < 10% penalize the innovations less for better fit
        lambda = 0.99*opts.lambda;
    end
    
    tau = max(10,100*exp((1-opts.iter)/100));
    theta = [1 -1/exp(1/tau)];
    
    %     m = beta1*m+(1-beta1)*gs(1:d,:);
    %     v = beta2*v+(1-beta2)*gs(1:d,:).^2;
    %     mhat = m/(1-beta1^iter);
    %     vhat = v/(1-beta2^iter);
    
    nmse_prev = opts.nmse_current;             % update nmse
    converged = convergence(y,E,opts);         % check if converged
    iter = opts.iter +1;                       % next iteration
    if mod(iter,100) == 0
        outStruct.x_init = x;
        fname = [opts.pwd filesep 'savedResults' filesep 'estimates'];
        save(fname,'outStruct');
    end
end

