function [y,yEmbedded,coeffs,x0] = preprocess(y,d,ToKeep,delay)
[coeffs,score] = pca(y','centered',false,'Numcomponents',ToKeep);
y = score';
EmbeddingDim = 2*d+1;


if delay > 0 
yEmbedded = embed(y,EmbeddingDim,delay);
else
yEmbedded = y;
end
[~,x0] = pca(yEmbedded','centered',false,'Numcomponents',d+1);
x0 = x0';


%% whiten data
% slows down convergence of the algorithm
% [U,S,V] = svd(y);
% y = S*V';
% y = V(:,1:ToKeep)';
end

