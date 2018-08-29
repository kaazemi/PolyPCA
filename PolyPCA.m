function [A,x,X,Exponents,opts] = PolyPCA(y,d,maxDeg,opts)
%% Polynomial Prinicipal Component Analysis Algorithm
% Inputs:
% y: matrix of data to be fit
% d: latent dimension
% maxDeg: maximum polynomial degree to be fit
% opts: optional parameters
    % opts.fs = sampling frequency (optional), the samples will have a time unit
    % opts.x_init = initial estimate of the latents: should be of size
    % (d+1)*T, where T is the number of samples in data matrix, 
    % last row of x will be set to 1 automatically.
% Outputs:
% A: coefficients of the fit monomials
% x: latents
% X: monomials resulting from the latents
% Exponents: monomial exponents in lexicographic order
%%%%%%%%%% Copyright 2018 by Abbas Kazemipour %%%%%%%%%%%%%
%%%%%%%%%%%% Last updated on 08-29-2018 %%%%%%%%%%%%%%%%%%%
% Notes:
% Learning rate should drop with 1/iter
clc;
rng(12,'twister'); opts.pwd = pwd;
% choose default solver parameters
opts = PolyPCA_DefaultParams(y,d,maxDeg,opts);
PolyPCA_messages('start',opts.d,opts.maxDeg)
Exponents =  sortPoly(opts.d,opts.maxDeg);      % sorts all the exponents in monomials or order <= maxDeg in d variables.

%% preprocess using PCA and Delayed embedding

% preprocess data by PCA or other linear transforms to reduce dimensionality
[y,opts] = preprocess(y,opts); 
% [beta1,beta2,m,v,mhat,vhat,alpha,epsilon] = AdamDefaultParams;
% initialize the solver
[A,s,x,X] = InitializePolyPCA(y,Exponents,opts);
% pos = plotX(x,d,c,iter,nmse_prev,pos);       % display the latents

%% perform gradient descent
while ~opts.converged
    E = y-A*X;                                              % residual
    opts.nmse_current = 100*norm(E,'fro')/norm(y,'fro');    % estimate of nmse
    switch opts.algorithm                                   % choose the gradient type based on the chosen norm
        case 'l2_Poly_PCA'                                  % backprojected error signal gets calculated first
    EbackProj = A'* E;
        case 'l1_Poly_PCA'
    EbackProj = A'* sign(E);
    end
    dp = dpenalty(s,opts.penalty,opts.p);                       % gradient of the penalty function on innovations
    dx = dX2dx(x,Exponents);                                    % gradient of the monomials in latents
    gx = gradx(dx,EbackProj);                                   % overall gradient with respect to the latents
    gs = fliplr(filter(1,opts.theta,fliplr(gx),[],2)) + opts.lambda.*dp;  % overall gradient with respect to innovations
%     gs = gs + randn(size(gs)).*(opts.saddleSigma);            % add random noise to escape saddle points
    s(1:opts.d,:) = s(1:opts.d,:) - opts.etaS*gs(1:opts.d,:);   % gradient descent on innovations
%     s(1:opts.d,:) = s(1:opts.d,:) - alpha*mhat./(sqrt(vhat)+epsilon).*gs(1:opts.d,:);           % gradient descent on innovations
    x(1:opts.d,:) = filter(1,opts.theta,s(1:d,:),[],2);         % update latents by integrating innovations
    x = x + opts.saddleSigma*randn(size(x));                    % add random noise to escape saddle points
    x = postprocess(x,opts);
    [opts.etaS,~,opts.lambda,~,opts.nmse_prev,opts.converged,opts.iter] = updatePolyPCAparams(y,E,x,opts);
    X = x2X(x,Exponents);                                   % transform latents to monomials
    y = orth(randn(opts.n))*y;
    PolyPCA_messages('rotatedY',opts.iter)
    A = y*X'/(X*X');                                        % perform least squares to obtain coefficients
    opts = plotX(x,opts);                                   % display the latents
end

end
