function gx = gradx(dx,EbackProj)
[n,T] = size(EbackProj);
d = size(dx,3);
gx = zeros(d,T);
for dim = 1:d
    for t = 1:T
        gx(dim,t) = -2*dx(:,t,dim)'*EbackProj(:,t)/n;
    end
end
end
