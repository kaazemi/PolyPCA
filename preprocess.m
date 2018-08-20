function [y,coeffs] = preprocess(y,d,ToKeep)
[coeffs,score] = pca(y','centered',false,'Numcomponents',ToKeep);
y = score';
end

