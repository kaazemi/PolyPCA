function [y,coeffs] = preprocess(y,ToKeep)
[coeffs,score] = pca(y','centered',false,'Numcomponents',ToKeep);
y = score';


%% whiten data
% slows down convergence of the algorithm
% [U,S,V] = svd(y);
% y = S*V';
% y = V(:,1:ToKeep)';
end

