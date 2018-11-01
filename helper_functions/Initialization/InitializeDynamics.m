if opts.Flags.Dynamics || isfield(opts,'theta')
    opts.theta = init([1 -.99],'theta',opts);    % Autoregressive model parameters for the latents: x_t = .99 x_{t-1} + s_t
                                                 % theta = 1 corresponds to no temporal structure.
    alpha = 1/(1+opts.theta(2))^2;
    opts.sigma2 = 1/(opts.params.T*alpha); % latent noise    
else
    opts.theta = 1;
end
opts.Flags.ThetaUpdate = false;