function x = Constrained_rank1_ALS(X,Exponents,opts)
ProjectAfter = true;
x = randn(opts.params.d+1,opts.params.T);
nElements = opts.params.d*opts.params.T;
if ~ProjectAfter
    x(end,:) = 1;
end
eta0 = 1e-3;
eta = eta0;
converged = 0; 
cnew = inf;
% iter = 0;
while ~converged
%     iter = iter+1;
    cold = cnew;
    x = x + eps;
    Xhat = x2X(x,Exponents);
    E = X-Xhat;
    dx = dX2dx(x,Exponents);
    gx = gradx(dx,E);
    M = (eta/eta0*gx./x).^2;
    cnew = sum(M(:))/nElements;
    converged = cnew < 0.01;
    x = x-eta*gx;
    x(end,:) = 1;    
    if cold < cnew
        eta = eta*.9;
    else
        eta = eta*1.01;
    end
    
end

plot(x')
end