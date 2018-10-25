function [s,x,X,opts] = LatentUpdate(x,s,gs,Exponents,opts)

    %     gs = gs + randn(size(gs)).*(opts.saddleSigma);            % add random noise to escape saddle points
switch lower(opts.GradientStep)
    case 'fixed'
        if opts.Flags.ClipGradient
            ClipBound = opts.ClipRatio*abs(s);
            IM = abs(gs) > ClipBound;
            gs(IM) = sign(gs(IM)).*ClipBound(IM);
        end
        gs = gs + opts.saddleSigma*randn(size(gs));        
        s(1:opts.d,:) = s(1:opts.d,:) - opts.etaS*gs(1:opts.d,:);       % gradient descent on innovations
    
    case 'adam'
    s(1:opts.d,:) = s(1:opts.d,:) - opts.DeltaS;                    % gradient descent (ADAM) on innovations
end

    x(1:opts.d,:) = ...
        filter(1,opts.theta,s(1:opts.d,:),[],2);        % update latents by integrating innovations
%     x = x + opts.saddleSigma*randn(size(x));                    	% add random noise to escape saddle points
    [x,opts] = postprocess(x,opts);
    X = x2X(x,Exponents);                                           % transform latents to monomials
end