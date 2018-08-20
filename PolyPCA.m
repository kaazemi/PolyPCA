function [A,x,X,Exponents] = PolyPCA(y,d,maxDeg,fs)
clc;
algorithm = 'l2_Poly_PCA';

% learning rate should drop with 1/iter
% unit norm of noise
%%
Exponents =  sortPoly(d,maxDeg);
ToKeep = nchoosek(d+maxDeg,d);
delay = 20;
%% preprocess using pca
[y,yEmbedded,coeffs,x0] = preprocess(y,d,ToKeep,delay);
 %% whiten data
% [U,S,V] = svd(y);
% y = S*V';
% y = V(:,1:ToKeep)';
[n,T] = size(y);
theta = [1 -.99];
% theta = 1;
etaS = 1e-3;
lambda = 100*ones(d+1,T);
% lambda = 0;
penalty = 'l2'; p = 2;
c = linspace(1,10,T);

%% Initialization Type I : Random spikes
% A = randn(n,ToKeep);
% s = randn(d+1,T);
% x = filter(1,theta,s,[],2);
% x = x./sum(x,2);
% x(end,:) = 1;
% X = x2X(x,Exponents);

% %% Initialization Type II: PCA+embedding
% A = randn(n,ToKeep);
x = x0;
x = x./sum(x,2);
x(end,:) = 1;
s = filter(theta,1,x,[],2);
X = x2X(x,Exponents);
A = y*X'/(X*X');

%%
iter = 1;
pos = 0;
converged = false;
nmse_prev = Inf;
while ~converged
    E = y-A*X;
    nmse_current = 100*norm(E,'fro')/norm(y,'fro');
    switch algorithm
        case 'l2_Poly_PCA'
    EbackProj = A'* E;
        case 'l1_Poly_PCA'
    EbackProj = A'* sign(E);
    end
    dp = dpenalty(s,penalty,p);
    dx = dX2dx(x,Exponents);
    gx0 = gradx(dx,EbackProj);
    gx = gx0 + randn(size(gx0)).*(1);
    gs = fliplr(filter(1,theta,fliplr(gx),[],2)) + lambda.*dp;
    s(1:d,:) = s(1:d,:) - etaS*gs(1:d,:);
    x(1:d,:) = filter(1,theta,s(1:d,:),[],2);
    x(end,:) = 1;
    
    pos = plotX(x,d,c,iter,nmse_current,pos);
    iter = iter +1;
    if nmse_current > nmse_prev
        etaS = 0.9*etaS;
    else
        etaS = 1.01*etaS;
    end
    nmse_prev = nmse_current;
    converged = convergence(y,E,iter);
    if nmse_current < 10
        lambda = 0.9*lambda;
    end
    X = x2X(x,Exponents);
    A = y*X'/(X*X');
end
end
