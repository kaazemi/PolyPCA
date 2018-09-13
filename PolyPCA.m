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
    % For more information about other options please see PolyPCA_DefaultParams.m
% Outputs:
% A: coefficients of the fit monomials
% x: latents
% X: monomials resulting from the latents
% Exponents: monomial exponents in lexicographic order
% opts: optimization parameters
%%%%%%%%%% Copyright 2018 by Abbas Kazemipour %%%%%%%%%%%%%
%%%%%%%%%%%% Last updated on 09-11-2018 %%%%%%%%%%%%%%%%%%%
% Notes:
% Learning rate should drop with 1/iter
clc;
% rng(12,'twister');
% choose default solver parameters
opts.pwd = pwd; 
opts = PolyPCA_DefaultParams(y,d,maxDeg,opts);
PolyPCA_messages('start',opts.d,opts.maxDeg)
Exponents =  sortPoly(opts.d,opts.maxDeg);      % sorts all the exponents in monomials or order <= maxDeg in d variables.

%% preprocess using PCA and Delayed embedding
% preprocess data by PCA or other linear transforms to reduce dimensionality
% [y,opts] = preprocess(y,opts); 
% initialize the solver
[A,s,x,X,E,opts] = InitializePolyPCA(y,Exponents,opts);
yMP = y; gA = 0;
%% perform gradient descent
while ~opts.converged
    gs = PolyPCAgrad(s,x,A,E,Exponents,opts);
    [s,x,X,opts] = LatentUpdate(x,s,gs,Exponents,opts); 
    if opts.SGD
        opts.SGSubset = sort(randsample(opts.n,opts.batchSize));
        yMP = y(opts.SGSubset,:);
    end
    [A,gA] = CoeffUpdate(yMP,A,X,opts);
    opts = updatePolyPCAparams(y,E,x,opts,gs,gA);
    E = y-A*X;                                              % residual
    opts.nmse_current = 100*norm(E,'fro')/norm(y,'fro');    % estimate of nmse
%     Q =  orth(randn(opts.n));
%     y = Q*y;
%     A = Q*A;
%     PolyPCA_messages('rotatedY',opts.iter)
    opts = plotX(x,opts);                                   % display the latents
end

end
