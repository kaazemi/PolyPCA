function [opts,params] = PolyPCA(y,d,maxDeg,opts)
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
% Output:
% opts: optimization parameters
%   opts.A: coefficients of the fit monomials
%   opts.x: latents
%   opts.X: monomials resulting from the latents
%   opts.Exponents: monomial exponents in lexicographic order
%%%%%%%%%% Copyright 2018 by Abbas Kazemipour %%%%%%%%%%%%%
%%%%%%%%%%%% Last updated on 10-25-2018 %%%%%%%%%%%%%%%%%%%
clc; warning('off')
% rng(12,'twister');
% choose default solver parameters
opts.pwd = pwd; 
[opts,y, Exponents,params] = PolyPCA_DefaultParams(y,d,maxDeg,opts);

% initialize the solver
[A,s,x,X,E,opts] = InitializePolyPCA(y,Exponents,opts);
% y = opts.LinearTransform*y;
gA = 0;
% load B; opts.Q = B; A  = A_gt; 
%% perform gradient descent
while ~opts.converged
    [gs,dLA,opts] = PolyPCAgrad(s,x,A,E,Exponents,opts);
    [s,x,X,opts] = LatentUpdate(x,s,gs,Exponents,opts); 
    switch lower(opts.algorithm)
        case 'convex'
            A = eye(opts.ToKeep);
%             [opts.Q,opts.Inv_QQt_Q] = SVP(X*y',opts.sigmaMin);%\(y*y') which is identity
%             y = opts.Q*y;
            % No CoeffUpdate
            A0 = y*X'/(X*X');
            E0 = y-A0*X;
            [opts,E] = updatePolyPCAparams(y,E0,A,x,X,opts,gs,gA);               
        otherwise
            [A,gA] = CoeffUpdate(y,A,dLA,X,opts);
            [opts,E] = updatePolyPCAparams(y,E,A,x,X,opts,gs,gA);   
    end
    opts = plotX(x,opts);                                   % display the latents
end
opts.yOut = y;
opts.Aout = A;
opts.Latents = x;
opts.LatentsVeronese = X;
opts.Exponents = Exponents;
end
