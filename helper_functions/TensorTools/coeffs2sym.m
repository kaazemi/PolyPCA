function S = coeffs2sym( A, d,maxDeg,iExponents,normalize )
if nargin < 5
    normalize = false;
end
[n,ToKeep] = size(A);
S = zeros([(d+1)^maxDeg,n]);
for i = 1:ToKeep
    I = iExponents == i;
    if normalize
        S(I,:) = repmat(A(:,i)',sum(I),1)/sqrt(sum(I));
    else
        S(I,:) = repmat(A(:,i)',sum(I),1);
    end
end

S = reshape(S,[(d+1)*ones(1,maxDeg),n]);
end

