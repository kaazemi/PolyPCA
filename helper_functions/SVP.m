function [Qp,Inv_QQt_Q] = SVP(Q,sigmaMin)
[m,p] = size(Q);
[U,S,V] = svd(Q);
if m <= p
D = max(diag(S(1:m,1:m)),sigmaMin);
    S(1:m,1:m) = diag(D);
else
    D = max(diag(S(1:p,1:p)),sigmaMin);
    S(1:p,1:p) = diag(D);
end
Qp = U*S*V';
Inv_QQt_Q = V'*diag(1./D.^2)*V*Qp';
end