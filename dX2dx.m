function dx = dX2dx(x,Exponents) %fixed?
[d,T] = size(x);
ToKeep = size(Exponents,1);
dx = zeros(ToKeep,T,d);
for dim = 1:d-1 %don't take gradient with respect to constant
    amdim = false(d,1);
    amdim(dim) = true;
    for t = 1:T
        dx(:,t,dim) = Exponents(:,dim).*(x(dim,t).^(Exponents(:,dim)-1)).*(prod(x(~amdim,t).^(Exponents(:,~amdim)')))';
    end
end
dx(isnan(dx)) = 0;
end

