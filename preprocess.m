function [y,opts] = preprocess(yin,opts)
[opts.coeffs,score] = pca(yin','centered',false,'Numcomponents',opts.ToKeep);
opts.yin = yin;
opts.nin = size(yin,1);
y = score';
%% whiten data
% slows down convergence of the algorithm
% [U,S,V] = svd(yin);
% y = S*V';
% y = V(:,1:opts.ToKeep)';
opts.n = size(y,1);
end

