function AQ = SymMultilinearTprod(A,Q)
k = length(size(A));
d = size(Q,1);
AQ = A;
    for dim = 1:k
        if size(Q,2) > 1
            permorder = 1:k;
            permorder(dim) = 1;
            permorder(1) = dim;
            Z = reshape(permute(AQ,permorder),d,[]);
            QZ = Q*Z;
            AQ = permute(reshape(QZ,d*ones(1,k)),permorder);
        else
            AQ = reshape(AQ,[],d)*Q;
        end
    end
end