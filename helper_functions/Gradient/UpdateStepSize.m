switch lower(opts.GradientStep)
    case 'fixed'
        if opts.nmse_current > opts.nmse_prev                     % update the step size with a momentum for better convergence
            opts.etaS = 0.95*opts.etaS;
            opts.etaA(:,opts.SelColumns) = 0.95*opts.etaA(:,opts.SelColumns);
            %         etaS = opts.etaS*opts.iter/(opts.iter+1);
        else
            opts.etaS = 1.01*opts.etaS;
            opts.etaA(:,opts.SelColumns) = 1.01*opts.etaA(:,opts.SelColumns);
        end
    case 'adam'
        opts.Adam.m = opts.Adam.beta1*opts.Adam.m +...
            (1-opts.Adam.beta1)*gs(1:opts.params.d,:);
        opts.Adam.v = opts.Adam.beta2*opts.Adam.v +...
            (1-opts.Adam.beta2)*gs(1:opts.params.d,:).^2;
        opts.Adam.mhat = opts.Adam.m/(1-opts.Adam.beta1^opts.iter);
        opts.Adam.vhat = opts.Adam.v/(1-opts.Adam.beta2^opts.iter);
        opts.DeltaS = opts.Adam.mhat./sqrt(opts.Adam.vhat+opts.Adam.epsilon);
        switch lower(opts.CoeffsUpdate)
            case 'gd'
                opts.Adam.Coeffs.m(opts.SGSubset,:) = opts.Adam.Coeffs.beta1*opts.Adam.Coeffs.m(opts.SGSubset,:) + (1-opts.Adam.Coeffs.beta1)*gA;
                opts.Adam.Coeffs.v(opts.SGSubset,:) = opts.Adam.Coeffs.beta2*opts.Adam.Coeffs.v(opts.SGSubset,:)+(1-opts.Adam.Coeffs.beta2)*gA.^2;
                opts.Adam.Coeffs.mhat(opts.SGSubset,:) = opts.Adam.Coeffs.m(opts.SGSubset,:)/(1-opts.Adam.Coeffs.beta1^opts.iter);
                opts.Adam.Coeffs.vhat(opts.SGSubset,:) = opts.Adam.Coeffs.v(opts.SGSubset,:)/(1-opts.Adam.Coeffs.beta2^opts.iter);
                opts.DeltaA = opts.Adam.Coeffs.mhat(opts.SGSubset,:)./sqrt(opts.Adam.Coeffs.vhat(opts.SGSubset,:)+opts.Adam.Coeffs.epsilon);
        end
        
end