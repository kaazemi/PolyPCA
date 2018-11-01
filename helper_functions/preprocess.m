function [y,opts,params] = preprocess(yin,opts,params)
% yin = yin./sqrt(sum(yin.^2,2)); yin(isnan(yin))=0;


if opts.Flags.Preprocess
    params.tfCounter = params.tfCounter+1;
    params.transferFcn{params.tfCounter}.Method = 'Subtract Mean';
    params.transferFcn{params.tfCounter}.ValueDescription = 'temporal mean of y';
    params.transferFcn{params.tfCounter}.Value = mean(yin,2);
    
    [coeff,score,~,~,explained,~] = pca(yin');
    y = score(:,1:find(cumsum(explained)>opts.var2Keep,1,'first')+1)';
    
    params.tfCounter = params.tfCounter+1;
    params.transferFcn{params.tfCounter}.Method = 'Project Down using PCA';
    params.transferFcn{params.tfCounter}.ValueDescription = 'Projection coefficients';
    params.transferFcn{params.tfCounter}.Value = coeff';
    

    
%     [params.S,params.U,params.V] = svd(yin-mean(yin,2));
%     d1 = size(params.U,1);
%     sigmas = diag(params.U(1:d1,1:d1)).^2;
%     sigmas = 100*sigmas/sum(sigmas);
%     NumComponents = max(find(cumsum(sigmas)>opts.var2Keep,1,'first'),opts.params.ToKeep);
%     y = params.V(:,1:NumComponents)';
else
    y = yin;
%     [params.S,params.U,params.V] = svd(y);
end
params.yin = yin;
params.nin = size(yin,1);

% y = y./sqrt(sum(y.^2,2)); y(isnan(y)) = 0;

%% whiten data
% slows down convergence of the algorithm
% [U,S,V] = svd(yin);
% y = S*V';
% y = V(:,1:opts.params.ToKeep)';
end

