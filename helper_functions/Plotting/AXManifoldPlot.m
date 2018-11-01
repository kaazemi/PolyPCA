function Qmin = AXManifoldPlot(opts)
nVar = opts.params.Solver.LatentDimension;
maxDeg = opts.params.Solver.MaximumPolynomialDegree;
[~,iExponents] = sortPoly(nVar,maxDeg);
ASym = coeffs2sym( opts.Aout, nVar,maxDeg,iExponents,true);
nQ = 1e6;
Qxnorm = zeros(1,nQ);
AQnorm = zeros(1,nQ);
sumNorms = zeros(1,nQ);
Qmin = eye(nVar+1);
minsumNorms = inf;
for i = 1:nQ
    if i == 1
        Q = eye(nVar+1);
    else
        Q = randn(nVar);
        Q(nVar+1,nVar+1) = 1;
        Q(end) = 1;
    end
    invQ = inv(Q);
    Qx = Q(1:nVar,1:nVar)*opts.Innovations(1:nVar,:);
    AQ = tensorProduct(ASym,invQ,1:maxDeg);
    Qxnorm(i) = norm(Qx,'fro')^2;
    AQnorm(i) = sum(AQ(:).^2);
    sumNorms(i) = opts.params.GradientDescent.Penalty.CoeffPenalty.Value*AQnorm(i) + ...
    opts.params.GradientDescent.Penalty.LatentInnovationPenalty.Value*Qxnorm(i);
    if sumNorms(i) < minsumNorms
        Qmin = Q;
        minsumNorms = sumNorms(i);
    end
end
plot(Qxnorm,AQnorm,'o');

end

