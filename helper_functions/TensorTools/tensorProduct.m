function S = tensorProduct(S,Q,modes)
modes = sort(modes);
s = size(S);
if ismatrix(S)
    s = [s,1];
end
d = s(1)-1;
maxDeg = length(s)-1; 
n = s(end);
targetDim = size(Q,2);
starget = s;

for i = 1:length(modes)
    mode = modes(i);
    starget(mode) = targetDim;
    permutation = [1:mode-1,mode+1:maxDeg+1,mode];
    invpermutation = [1:mode-1,maxDeg+1,mode:maxDeg];
    SQ = reshape(reshape(permute(S,permutation),[],d+1)*Q,starget(permutation));
    S = permute(SQ,invpermutation);
end
end


