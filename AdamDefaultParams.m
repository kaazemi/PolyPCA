function [beta1,beta2,m,v,mhat,vhat,alpha,epsilon] = AdamDefaultParams
beta1 = 0.9;
beta2 = 0.999;
m = 1e-3;
v = 1e-3;
alpha = 0.001;
epsilon = 1e-8;
mhat = 0;
vhat = 0;
end