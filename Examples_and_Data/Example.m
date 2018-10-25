% In order to recontruct the example in the paper load Data.mat and run
% [A,x,X,Exponents] = PolyPCA(y,2,2,opts);

%% How to Use this code:
%% Step 1: Generate latent variables and observations
latent_generator 
% simply generates a nonlinear latent variable, this has been changed from
% the paper to add more nonlinearity. You are welcome to change it to other
% nonlinearities

%% Step 2: Run Poly-PCA
d = 2; %latent dimension
maxDeg = 2; %maximum polynomial degree
opts = PolyPCA(y,d,maxDeg);