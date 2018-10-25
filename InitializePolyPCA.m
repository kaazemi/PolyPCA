function [A,s,x,X,E,opts] = InitializePolyPCA(y,Exponents,opts)
addpath(genpath(pwd));
switch opts.algorithm
    case {'ALS','als'}
        opts.initialization_type = 'ALS';        
end
if isfield(opts,'x_init')
    opts.initialization_type = 'user';
end
PolyPCA_messages('initialization',opts.initialization_type)
switch opts.initialization_type
    case 'zeros'
        A = randn(opts.n,opts.ToKeep); PolyPCA_messages('Coeffs','random Gaussians')
        x = zeros(opts.d+1,opts.T);
        x(end,:) = 1;
        s = filter(opts.theta,1,x,[],2);
        X = x2X(x,Exponents);
    case 'ones'
        g = sum(abs(y).^(1/opts.maxDeg));
        x = g.*ones(opts.d+1,opts.T);
        x(end,:) = 1;
        s = filter(opts.theta,1,x,[],2);
        X = x2X(x,Exponents);     
        A = randn(opts.n,opts.ToKeep); PolyPCA_messages('Coeffs','random Gaussians')        
    case 'random'
        %% Initialization Type I : Random spikes
        s = 0.01*randn(opts.d+1,opts.T);
        x = filter(1,opts.theta,s,[],2);
%         x = normr(x);
        x = x./sum(x,2);
        x(end,:) = 1;
        X = x2X(x,Exponents);
        A = y*X'/(X*X'+eye(opts.ToKeep)*1e-4); PolyPCA_messages('Coeffs','least squares')
    case {'EMPCA','PCA'} % Delayed Embedding + PCA
        %% Initialization Type II: Embedding+PCA
        
        if opts.delay == 0 || strcmp(opts.initialization_type,'PCA')
            yEmbedded = y;
        else
            EmbeddingDim = 2*opts.d+1;
            yEmbedded = embed(y,EmbeddingDim,opts.delay);
            PolyPCA_messages('Embedding',opts.delay,EmbeddingDim);
        end
        [~,x] = pca(yEmbedded','centered',false,'Numcomponents',opts.d+1);
        
        x = x';
        x = x./sum(x,2);
        x(end,:) = 1;
        s = filter(opts.theta,1,x,[],2);
        X = x2X(x,Exponents);
        A = 0.01*y*X'/(X*X'); PolyPCA_messages('Coeffs','least squares')
        
    case 'spherical'
%         x = randn(opts.d+1,opts.T);
%         x = x./sqrt(sum(x(1:opts.d,:).^2));
        ynorms = (sum(abs(y).^opts.maxDeg)).^(1/opts.maxDeg);
        theta = linspace(0,2*pi,opts.T);
        x = ones(opts.d+1,opts.T);
        
        for m = 1:opts.d-1
            x(m,:) = cos(theta).^m;
        end
        x(opts.d,:) = cos(theta).^(opts.d-2).*sin(theta);
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
         A = randn(opts.n,opts.ToKeep); PolyPCA_messages('Coeffs','random Gaussians');
end
    E = (y-A*X);                                              % residual
    opts.nmse_current = 100*norm(E,'fro')/norm(y,'fro');    % estimate of nmse
%     RelE = E./(y-A(:,1));
%     C = sum(RelE.^2)/opts.n;
%     opts.TruncateIndices = C < prctile(C,5);
end

