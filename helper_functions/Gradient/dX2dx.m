function dx = dX2dx(x,Exponents) %fixed?
x = x+rand*eps;
[d,T] = size(x);
ToKeep = size(Exponents,1);
dx = zeros(ToKeep,T,d);
for dim = 1:d %don't take gradient with respect to constant
    amdim = false(d,1);
    amdim(dim) = true;
    for t = 1:T
        if x(dim,t)
            dx(:,t,dim) = Exponents(:,dim).*(x(dim,t).^(Exponents(:,dim)-1)).*(prod(x(~amdim,t).^(Exponents(:,~amdim)')))';
        end
    end
end
dx(isnan(dx)) = 0;
end

