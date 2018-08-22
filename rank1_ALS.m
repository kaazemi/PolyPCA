function [x,x_reordered,X] = rank1_ALS(X,d,k)
% Finds the best rank 1 estimate to X
% Each column of X is the vectorized form of the lower triangular part of the tensor x(^k)
[~,T] = size(X);
x = zeros(d+1,T);
[Exponents,iExponents] = sortPoly(d,k);
for t = 1:T
    z = rand(d+1,1);
%     z = [1;2;3];
    symX = zeros((d+1)*ones(1,k));
    for i = 1:numel(symX)
    symX(i) = X(iExponents(i),t);
    end
    symX = reshape(symX,d+1,[]);
    S = sum(symX(:));
    for iter = 1:100
        Z = tprod(z,k-1);
        z = symX*Z/(Z'*Z+1e-6);
        alpha = (S/sum(tprod(z,k)))^(1/k);
        if isreal(alpha)
            z = z*alpha;
        end
    end
    x(:,t) = z;

    X(:,t) = x2X(z,Exponents);
end
    x_reordered = reorder(x);
end

function Z = tprod(z,k)
Z = z;
for deg = 1:k-1
    Z = kron(Z,z);
end
end

function xr = reorder(x)
[~,I] = min(abs(x-1));
[d,T] = size(x);
xr = x;
for t = 1:T
    permorder = 1:d;
    permorder(d) = I(t);
    permorder(I(t)) = d;
xr(:,t) = x(permorder,t);
end
xr(end,:) = 1;
end