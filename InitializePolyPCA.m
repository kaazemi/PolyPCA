function [A,s,x,X] = InitializePolyPCA(type,y,maxDeg,n,ToKeep,d,T,theta,Exponents,delay)
addpath(genpath(pwd));
PolyPCA_messages('initialization',type)
switch type
    case 'random' 
        %% Initialization Type I : Random spikes
        A = randn(n,ToKeep); PolyPCA_messages('Coeffs','random Gaussians')
        s = randn(d+1,T);
        x = filter(1,theta,s,[],2);
        x = x./sum(x,2);
        x(end,:) = 1;
        X = x2X(x,Exponents);
    case {'EMPCA','PCA'} % Delayed Embedding + PCA
        %% Initialization Type II: Embedding+PCA
        
        if delay == 0 || strcmp(type,'PCA') 
            yEmbedded = y;
        else
            EmbeddingDim = 2*d+1;
            yEmbedded = embed(y,EmbeddingDim,delay);
            PolyPCA_messages('Embedding',delay,EmbeddingDim);
        end
        [~,x] = pca(yEmbedded','centered',false,'Numcomponents',d+1);

        x = x';
        x = x./sum(x,2);
        x(end,:) = 1;
        s = filter(theta,1,x,[],2);
        X = x2X(x,Exponents);
        A = y*X'/(X*X'); PolyPCA_messages('Coeffs','least squares')
    case 'ROTPCA' % PCA + Rotation
        
        [L,Centers] = kmeans(y',ToKeep);
        Centers = Centers';
        x = zeros(d+1,T);
%         R = randn(d+1,ToKeep);        
%         R(end,:) = 1;
        [~,Rr,~,RrX] = rank1_ALS(Centers,d,maxDeg,true);
%         for clusterNum = 1:ToKeep
%             indices = L == clusterNum;
%             x(:,indices) = repmat(Rr(:,clusterNum),1,sum(indices));
%         end
%         s = filter(theta,1,x,[],2);    
%         X = x2X(x,Exponents);
%         A = y*X'/(X*X')+randn(n,ToKeep);
        Q = RrX/Centers;
        yr = Q*y;

        x = rank1_ALS(yr,d,maxDeg,false);
        x(end,:) = 1;
        s = filter(theta,1,x,[],2);   
        X = x2X(x,Exponents);
        A = y*X'/(X*X'); PolyPCA_messages('Coeffs','least squares')
        
        case 'ROOTGPCA' % Root + GPCA %incomplete
        rtym = (y - min(y,[],2)).^(1/maxDeg);
        g = gpca_pda_spectralcluster(rtym,d);
        
            
end
        
end

