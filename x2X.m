function X = x2X(x,Exponents) %fixed
[~,T] = size(x);
ToKeep = size(Exponents,1);
X = zeros(ToKeep,T);
for t = 1:T
    X(:,t) = prod(x(:,t)'.^Exponents,2);
end
end