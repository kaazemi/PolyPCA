function [s,x,X,opts] = LatentUpdate(x,s,gs,Exponents,opts)
    %     gs = gs + randn(size(gs)).*(opts.params.saddleSigma);         % add random noise to escape saddle points
switch lower(opts.GradientStep)
    case 'fixed'
        if opts.Flags.ClipGradient
            ClipBound = opts.params.ClipRatio*abs(s);
            IM = abs(gs) > ClipBound;
            gs(IM) = sign(gs(IM)).*ClipBound(IM);
        end
        if opts.Flags.AddSaddleNoise
            gs = gs + opts.params.saddleSigma*randn(size(gs));
        end
        s(1:opts.params.d,:) = s(1:opts.params.d,:) - opts.etaS*gs(1:opts.params.d,:);       % gradient descent on innovations
    
    case 'adam'
    s(1:opts.params.d,:) = s(1:opts.params.d,:) - opts.DeltaS;                    % gradient descent (ADAM) on innovations
end

    x(1:opts.params.d,:) = ...
        filter(1,opts.theta,s(1:opts.params.d,:),[],2);        % update latents by integrating innovations
%     x = x + opts.params.saddleSigma*randn(size(x));   % add random noise to escape saddle points

    [x,opts] = postprocess(x,opts);
%     s(1:opts.params.d,:) = filter(opts.theta,1,x(1:opts.params.d,:),[],2);
    X = x2X(x,Exponents);                                           % transform latents to monomials
end