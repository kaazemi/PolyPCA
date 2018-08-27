function [etaS,saddleSigma,lambda,theta] = updatePolyPCAparams(iter,nmse_current,nmse_prev,etaS,saddleSigma,lambda)

    
    if nmse_current > nmse_prev                     % update the step size with a momentum for better convergence
        etaS = 0.95*etaS;
        saddleSigma = 0.9*saddleSigma;
%         etaS = etaS*iter/(iter+1);
    else
        if nmse_current > .95*nmse_prev
            saddleSigma = 1.1*saddleSigma;
        else
            saddleSigma = 0.9*saddleSigma;
        end
%         etaS = 1.01*etaS;
    end
    if nmse_current < 10                            % if error < 10% penalize the innovations less for better fit
        lambda = 0.99*lambda;                        
    end
    
    tau = max(10,100*exp((1-iter)/100));
    theta = [1 -1/exp(1/tau)];
    
    %     m = beta1*m+(1-beta1)*gs(1:d,:);
    %     v = beta2*v+(1-beta2)*gs(1:d,:).^2;
    %     mhat = m/(1-beta1^iter);
    %     vhat = v/(1-beta2^iter);

end

