function [x,e] = best_sym_rank1(T,EmbeddingDim)

d = size(T,1);
if nargin<2
    EmbeddingDim = d;
end
k = ndims(T);
TEmbedded = zeros(EmbeddingDim*ones(1,k));
S.subs = repmat({1:d},1,k);
S.type = '()';
TEmbedded = subsasgn(TEmbedded,S,T);
x = randn(EmbeddingDim,1);
symX = reshape(TEmbedded,EmbeddingDim,[]);
S = sum(symX(:));
for iter = 1:100
    Z = tprod(x,k-1);
    x = symX*Z/(Z'*Z+1e-6);
    alpha = (S/sum(tprod(x,k)))^(1/k);
    if isreal(alpha)
        x = x*alpha;
    end
end

X = tprod(x(1:d),k);
e = norm(X(:)-T(:));

end

function Z = tprod(z,k)
    Z = z;
    for deg = 1:k-1
        Z = kron(Z,z);
    end
end
