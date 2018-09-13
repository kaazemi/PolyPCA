function opts = updatePolyPCAparams(y,E,x,opts,gs,gA)

switch opts.GradientStep
    case 'fixed'
        if opts.nmse_current > opts.nmse_prev                     % update the step size with a momentum for better convergence
            opts.etaS = 0.95*opts.etaS;
            opts.etaA = 0.95*opts.etaA;
            %         etaS = opts.etaS*opts.iter/(opts.iter+1);
        else
            opts.etaS = 1.01*opts.etaS;
            opts.etaA = 1.01*opts.etaA;
        end
    case {'Adam','ADAM'}
        opts.Adam.m = opts.Adam.beta1*opts.Adam.m + (1-opts.Adam.beta1)*gs(1:opts.d,:);
        opts.Adam.v = opts.Adam.beta2*opts.Adam.v+(1-opts.Adam.beta2)*gs(1:opts.d,:).^2;
        opts.Adam.mhat = opts.Adam.m/(1-opts.Adam.beta1^opts.iter);
        opts.Adam.vhat = opts.Adam.v/(1-opts.Adam.beta2^opts.iter);
        opts.DeltaS = opts.Adam.mhat./sqrt(opts.Adam.vhat+opts.Adam.epsilon);
        switch opts.CoeffsUpdate
            case 'GD'
                opts.Adam.Coeffs.m(opts.SGSubset,:) = opts.Adam.Coeffs.beta1*opts.Adam.Coeffs.m(opts.SGSubset,:) + (1-opts.Adam.Coeffs.beta1)*gA;
                opts.Adam.Coeffs.v(opts.SGSubset,:) = opts.Adam.Coeffs.beta2*opts.Adam.Coeffs.v(opts.SGSubset,:)+(1-opts.Adam.Coeffs.beta2)*gA.^2;
                opts.Adam.Coeffs.mhat(opts.SGSubset,:) = opts.Adam.Coeffs.m(opts.SGSubset,:)/(1-opts.Adam.Coeffs.beta1^opts.iter);
                opts.Adam.Coeffs.vhat(opts.SGSubset,:) = opts.Adam.Coeffs.v(opts.SGSubset,:)/(1-opts.Adam.Coeffs.beta2^opts.iter);
                opts.DeltaA = opts.Adam.Coeffs.mhat(opts.SGSubset,:)./sqrt(opts.Adam.Coeffs.vhat(opts.SGSubset,:)+opts.Adam.Coeffs.epsilon);
        end
        
end

if opts.Flags.SaddleSigmaUpdate
    if opts.nmse_current > opts.nmse_prev                     % update the step size with a momentum for better convergence
        opts.saddleSigma = 0.9*opts.saddleSigma;
    elseif opts.nmse_current > .95*opts.nmse_prev
        opts.saddleSigma = 1.1*opts.saddleSigma;
    else
        opts.saddleSigma = 0.9*opts.saddleSigma;
    end
end

if opts.nmse_current < 10                                  % if error < 10% penalize the innovations less for better fit
    opts.lambda = 0.99*opts.lambda;
end
if opts.Flags.ThetaUpdate
    tau = max(10,100*exp((1-opts.iter)/100));
    opts.theta = [1 -1/exp(1/tau)];
end



opts.nmse_prev = opts.nmse_current;             % update nmse
if opts.iter > 1
    opts.converged = convergence(y,E,opts);         % check if converged
end
opts.iter = opts.iter +1;                       % next iteration
if mod(opts.iter,100) == 0
    outStruct.x_init = x;
    fname = [opts.pwd filesep 'savedResults' filesep 'estimates'];
    save(fname,'outStruct','opts');
end
end

