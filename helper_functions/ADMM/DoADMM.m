if opts.iter == 1
    for k = 1:opts.params.maxDeg
       opts.ADMM.x{k} = randn(size(x));
       opts.ADMM.s{k} = filter(opts.theta,1,x,[],2);
       opts.ADMM.gs{k} = nan(size(s));
       opts.ADMM.A{k} = nan(size(s));
       opts.ADMM.gamma{k} = .1*ones(size(x));
       opts.ADMM.gamma{k}(end,:) = 0;
    end
    opts.ADMM.x{1} = x;
    opts.ADMM.sigma = .1;
    opts.ADMM.eta = 1;
    AX = cell(opts.params.maxDeg,opts.params.T);
end

SymA = coeffs2sym(A,opts.params.d,opts.params.maxDeg,params.iExponents);

for k = 1:opts.params.maxDeg
modes = [1:k-1,k+1:opts.params.maxDeg];
    for t = 1:opts.params.T
        AX{k,t} = SymA;
        for i = 1:opts.params.maxDeg-1
            mode = modes(i);
            AX{k,t} = tensorProduct(AX{k,t},opts.ADMM.x{i}(:,t),mode);
        end
            AX{k,t} = squeeze(AX{k,t})';
    end
end

% Gradient on each x
% d(sigma/2 ||x-x_i||^2
for k = 1:opts.params.maxDeg
    for t = 1:opts.params.T
        gx1{k}(:,t) = -AX{k,t}'*(y(:,t)-AX{k,t}*opts.ADMM.x{k}(:,t));
    end
    if k == 1
        gx2{k} = opts.ADMM.sigma*(opts.ADMM.x{k}-opts.ADMM.x{k+1});
        gx3{k} = -(opts.ADMM.gamma{k}-opts.ADMM.gamma{k+1});
    elseif k == opts.params.maxDeg
        gx2{k} = opts.ADMM.sigma*(opts.ADMM.x{k}-opts.ADMM.x{k-1});
        gx3{k} = -(opts.ADMM.gamma{k}-opts.ADMM.gamma{k-1});
    else
        gx2{k} = opts.ADMM.sigma*(2*opts.ADMM.x{k}-opts.ADMM.x{k-1}-opts.ADMM.x{k+1});
        gx3{k} = -(2*opts.ADMM.gamma{k}-opts.ADMM.gamma{k-1}-opts.ADMM.gamma{k+1});
    end
        gs1{k} = fliplr(filter(1,opts.theta,fliplr(gx1{k}),[],2));
        gs2{k} = fliplr(filter(1,opts.theta,fliplr(gx2{k}),[],2));
        gs3{k} = fliplr(filter(1,opts.theta,fliplr(gx3{k}),[],2));
        gs4{k} = opts.lambda*filter(opts.theta,1,opts.ADMM.x{k},[],2);
        opts.ADMM.s{k} = opts.ADMM.s{k}-opts.etaS*(gs1{k}+gs2{k}+gs3{k}+gs4{k});
        opts.ADMM.x{k} = filter(1,opts.theta,opts.ADMM.s{k},[],2);
end
gs = gs1{2}+gs2{1}+gs3{1}+gs4{1};

% gradient is always on s and then translated to x
% find gs,s,x, 
%     should do post processing on each x
for k = 1:opts.params.maxDeg
    opts.ADMM.x{k} = postprocess(opts.ADMM.x{k},opts);
end
    [x,opts] = postprocess(opts.ADMM.x{1},opts);

% Find X by symmetrizing X
for t = 1:opts.params.T
    tensorX = x(:,t);
    for k = 1:opts.params.maxDeg-1
        tensorX = kron(tensorX,opts.ADMM.x{k}(:,t));
    end
    tensorX = reshape(tensorX,(opts.params.d+1)*ones(1,opts.params.maxDeg));
    X(:,t) = sym2coeffs(tensorX,params.iExponents);
end



% Find A by LS as before
A = CoeffUpdate(y,A,dLA,X,opts);

% No need to calculate error differently
[opts,E] = updatePolyPCAparams(y,E,A,x,s,X,opts,gs,gA);
