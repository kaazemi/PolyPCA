function [A,x,X,Exponents] = PolyPCA(y,d,maxDeg,fs)
%% Polynomial Prinicipal Component Analysis Algorithm
% Inputs:
% y: matrix of data to be fit
% d: latent dimension
% maxDeg: maximum polynomial degree to be fit
% fs: sampling frequency (optional)
% Outputs:
% A: coefficients of the fit monomials
% x: latents
% X: monomials resulting from the latents
% Exponents: monomial exponents in lexicographic order
%%%%%%%%%% Copyright 2018 by Abbas Kazemipour %%%%%%%%%%%%%
%%%%%%%%%%%% Last updated on 08-20-2018 %%%%%%%%%%%%%%%%%%%
clc;
rng(12,'twister');
algorithm = 'l2_Poly_PCA'; % minimizes the frobenius norm of error,
                           % l1_Poly_PCA is work in progress
PolyPCA_messages('start',d,maxDeg)
% Notes:
% Learning rate should drop with 1/iter

%%
Exponents =  sortPoly(d,maxDeg); % sorts all the exponents in monomials or order <= maxDeg in d variables.
ToKeep = nchoosek(d+maxDeg,d);   % number of monomials of order <= maxDeg in d variables
delay = 20;                      % Delay value used in embedding of the PC components (in samples).
%% preprocess using PCA and Delayed embedding
% preprocess data by PCA or other linear transforms to reduce dimensionality
[y,coeffs] = preprocess(y,ToKeep); 
% choose default solver parameters
[n,T,theta,etaS,lambda,penalty,p,c,iter,pos,converged,nmse_prev,type,saddleSigma] = PolyPCA_DefaultParams(y,d);
% [beta1,beta2,m,v,mhat,vhat,alpha,epsilon] = AdamDefaultParams;
% initialize the solver
[A,s,x,X] = InitializePolyPCA(type,y,maxDeg,n,ToKeep,d,T,theta,Exponents,delay);
% pos = plotX(x,d,c,iter,nmse_prev,pos);       % display the latents

%% perform gradient descent
while ~converged
    E = y-A*X;                                      % residual
    nmse_current = 100*norm(E,'fro')/norm(y,'fro'); % estimate of nmse
    switch algorithm                                % choose the gradient type based on the chosen norm
        case 'l2_Poly_PCA'                          % backprojected error signal gets calculated first
    EbackProj = A'* E;
        case 'l1_Poly_PCA'
    EbackProj = A'* sign(E);
    end
    dp = dpenalty(s,penalty,p);                    % gradient of the penalty function on innovations
    dx = dX2dx(x,Exponents);                       % gradient of the monomials in latents
    gx = gradx(dx,EbackProj);                      % overall gradient with respect to the latents
    gs = fliplr(filter(1,theta,fliplr(gx),[],2)) + lambda.*dp;  % overall gradient with respect to innovations
%     gs = gs + randn(size(gs)).*(saddleSigma);      % add random noise to escape saddle points
    s(1:d,:) = s(1:d,:) - etaS*gs(1:d,:);          % gradient descent on innovations
%     s(1:d,:) = s(1:d,:) - alpha*mhat./(sqrt(vhat)+epsilon).*gs(1:d,:);           % gradient descent on innovations
    x(1:d,:) = filter(1,theta,s(1:d,:),[],2);       % update latents by integrating innovations
    x = x + saddleSigma*randn(size(x));             % add random noise to escape saddle points
    x = postprocess(x,iter);
    [etaS,~,lambda,~] = updatePolyPCAparams(iter,nmse_current,nmse_prev,etaS,saddleSigma,lambda);
    nmse_prev = nmse_current;                       % update nmse
    converged = convergence(y,E,iter);              % check if converged
    X = x2X(x,Exponents);                           % transform latents to monomials
    y = orth(randn(n))*y;
    PolyPCA_messages('rotatedY',iter)
    A = y*X'/(X*X');                                % perform least squares to obtain coefficients
    iter = iter +1;                                 % next iteration
    pos = plotX(x,d,c,iter,nmse_current,pos);       % display the latents

end
end
