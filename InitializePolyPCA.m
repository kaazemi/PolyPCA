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
        A = randn(opts.n,opts.ToKeep); PolyPCA_messages('Coeffs','random Gaussians')
        s = randn(opts.d+1,opts.T);
        x = filter(1,opts.theta,s,[],2);
        x = x./sum(x,2);
        x(end,:) = 1;
        X = x2X(x,Exponents);
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
        A = y*X'/(X*X'); PolyPCA_messages('Coeffs','least squares')
    case 'ROTPCA' % PCA + Rotation
        
        [L,Centers] = kmeans(y',opts.ToKeep);
        Centers = Centers';
        x = zeros(opts.d+1,opts.T);
        %         R = randn(d+1,ToKeep);
        %         R(end,:) = 1;
        [~,Rr,~,RrX] = rank1_ALS(Centers,opts.d,opts.maxDeg,true);
        %         for clusterNum = 1:ToKeep
        %             indices = L == clusterNum;
        %             x(:,indices) = repmat(Rr(:,clusterNum),1,sum(indices));
        %         end
        %         s = filter(theta,1,x,[],2);
        %         X = x2X(x,Exponents);
        %         A = y*X'/(X*X')+randn(n,ToKeep);
        Q = RrX/Centers;
        yr = Q*y;
        
        x = rank1_ALS(yr,opts.d,opts.maxDeg,false);
        x(end,:) = 1;
        s = filter(opts.theta,1,x,[],2);
        X = x2X(x,Exponents);
        A = y*X'/(X*X'); PolyPCA_messages('Coeffs','least squares')
        
    case 'ROOTGPCA' % Root + GPCA %incomplete
        rtym = (y - min(y,[],2)).^(1/opts.maxDeg);
        g = gpca_pda_spectralcluster(rtym,opts.d);
        
    case 'user'
        x = opts.x_init;
        x(end,:) = 1;
        s = filter(opts.theta,1,x,[],2);
        X = x2X(x,Exponents);
        A = y*X'/(X*X'); PolyPCA_messages('Coeffs','least squares')
    case 'ALS'
         A = randn(opts.n,opts.ToKeep); PolyPCA_messages('Coeffs','random Gaussians');
         
end
    E = y-A*X;                                              % residual
    opts.nmse_current = 100*norm(E,'fro')/norm(y,'fro');    % estimate of nmse   
end

