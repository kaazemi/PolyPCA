function [A,s,x,X,Sigmax,E,opts] = InitializePolyPCA(y,Exponents,opts)
addpath(genpath(pwd));
switch opts.objective
    case {'ALS','als'}
        opts.initialization_type = 'ALS';        
end
if isfield(opts,'x_init')
    opts.initialization_type = 'user';
end
PolyPCA_messages('initialization',opts.initialization_type)
switch opts.initialization_type
    case 'zeros'
        A = randn(opts.params.n,opts.params.ToKeep); PolyPCA_messages('Coeffs','random Gaussians')
        x = zeros(opts.params.d+1,opts.params.T);
        x(end,:) = 1;
        s = filter(opts.theta,1,x,[],2);
        X = x2X(x,Exponents);
    case 'ones'
        g = sum(abs(y).^(1/opts.params.maxDeg));
        x = g.*ones(opts.params.d+1,opts.params.T);
        x(end,:) = 1;
        s = filter(opts.theta,1,x,[],2);
        X = x2X(x,Exponents);     
        A = randn(opts.params.n,opts.params.ToKeep); PolyPCA_messages('Coeffs','random Gaussians')        
    case 'random'
        %% Initialization Type I : Random spikes
        s = 0.01*randn(opts.params.d+1,opts.params.T);
        x = filter(1,opts.theta,s,[],2);
        x(end,:) = 1;
        if opts.Flags.postProcess
            [x,opts] = postprocess(x,opts);
        end
        X = x2X(x,Exponents);
        A = y*X'/(X*X'+eye(opts.params.ToKeep)*1e-4); PolyPCA_messages('Coeffs','least squares')
    case {'EMPCA','PCA'} % Delayed Embedding + PCA
        %% Initialization Type II: Embedding+PCA
        if opts.delay == 0 || strcmp(opts.initialization_type,'PCA')
            yEmbedded = y;
        else
            EmbeddingDim = 2*opts.params.d+1;
            yEmbedded = embed(y,EmbeddingDim,opts.delay);
            PolyPCA_messages('Embedding',opts.delay,EmbeddingDim);
        end
        [~,x] = pca(yEmbedded','centered',false,'Numcomponents',opts.params.d+1);
        
        x = x';
        x = x./sum(x,2);
        x(end,:) = 1;
        s = filter(opts.theta,1,x,[],2);
        X = x2X(x,Exponents);
        A = 0.01*y*X'/(X*X'); PolyPCA_messages('Coeffs','least squares')
        
    case 'spherical'
%         x = randn(opts.params.d+1,opts.params.T);
%         x = x./sqrt(sum(x(1:opts.params.d,:).^2));
        ynorms = (sum(abs(y).^opts.params.maxDeg)).^(1/opts.params.maxDeg);
        theta = linspace(0,2*pi,opts.params.T);
        x = ones(opts.params.d+1,opts.params.T);
        
        for m = 1:opts.params.d-1
            x(m,:) = cos(theta).^m;
        end
        x(opts.params.d,:) = cos(theta).^(opts.params.d-2).*sin(theta);
%         x = x.*ynorms;
        x(end,:) = 1;
        s = filter(opts.theta,1,x,[],2);
        X = x2X(x,Exponents);
        A = 0.01*y*X'/(X*X'); PolyPCA_messages('Coeffs','least squares')
    case 'user'
        x = opts.x_init;
        x(end,:) = 1;
        s = filter(opts.theta,1,x,[],2);
        X = x2X(x,Exponents);
        A = y*X'/(X*X'); PolyPCA_messages('Coeffs','least squares')
    case 'ALS'
         A = randn(opts.params.n,opts.params.ToKeep); PolyPCA_messages('Coeffs','random Gaussians');
end
    E = (y-A*X);                                              % residual
    opts.nmse_current = 100*norm(E,'fro')/norm(y,'fro');    % estimate of nmse
    
    if opts.Flags.Dynamics
        Sigmax = opts.sigma2^2*ones(size(x));
    else
        Sigmax = 0;
    end
end

