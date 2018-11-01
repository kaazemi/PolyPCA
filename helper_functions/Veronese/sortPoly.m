function [E,iExponents,Elocs] = sortPoly(nVar,maxDeg)
% sorts monomials of maximum degree maxDeg in nVar variables in lexicographic order
% ith column in E corresponds to ith variable
P = primes(1000);
P = P(1:nVar+1);
 Exponents = zeros((nVar+1)^maxDeg,nVar+1); % x1 x2 ... xd 1
    K = P;
    for iter = 1:maxDeg-1
        K = kron(K,P);
    end
    for i = 1:length(K)
        a = factor(K(i));
        for j = 1:nVar+1
            Exponents(i,j) = sum(a == P(j));
        end
        
    end
%     Exponents(:,1) = 1;
    [E,Elocs,iExponents] = unique(Exponents,'rows'); 
end

