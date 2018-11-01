if opts.Flags.SaddleSigmaUpdate
    if opts.nmse_current > opts.nmse_prev                     % update the step size with a momentum for better convergence
        opts.saddleSigma = 0.9*opts.saddleSigma;
    elseif opts.nmse_current > .95*opts.nmse_prev
        opts.saddleSigma = 1.1*opts.saddleSigma;
    else
        opts.saddleSigma = 0.9*opts.saddleSigma;
    end
end