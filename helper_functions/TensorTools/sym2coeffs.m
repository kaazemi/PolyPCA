function A = sym2coeffs(S,iExponents)
if nargin < 3
    normalize = false;
end
s = size(S);
if ismatrix(S)
    s = [s 1];
end
d = s(1)-1;
maxDeg = length(s)-1; 
n = s(end);
ToKeep = nchoosek(d+maxDeg,maxDeg);
S = reshape(S,[(maxDeg+1)^d,n]);
A = zeros(n,ToKeep);
for i = 1:ToKeep    
    I = iExponents == i;
    if normalize
        A(:,i) = sum(S(I,:))/sqrt(sum(I));
    else
        A(:,i) = sum(S(I,:))/sum(I);
    end
end
end

