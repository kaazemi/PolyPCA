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
[opts,y,params] = PolyPCA_DefaultParams(y,d,maxDeg,opts);

% initialize the solver
[A,s,x,X,Sigmax,E,opts] = InitializePolyPCA(y,params.Exponents,opts);
gA = 0; dLA = 0;

% load B; opts.Q = B; A  = A_gt; 
%% perform gradient descent
while ~opts.converged
    switch lower(opts.SolverAlgorithm)
            case 'power'
                DoPowerIteration
            case 'vgd'
                DoVanillaGradientDescent
            case 'admm'
                DoADMM
        otherwise 
            error
    end
    opts = plotX(x,opts);                                   % display the latents
end
opts.Innovations = s;
opts.yOut = y;
opts.Aout = A;
opts.Latents = x;
opts.LatentsVeronese = X;
opts2params;
opts.params = params;
end
