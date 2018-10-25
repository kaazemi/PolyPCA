function opts = updateMinimaxParams(opts,E)
    C = cov(E');
    [V,~] = eig(C);
    opts.VMinimax = V(:,end-opts.params.NumSingularValues2Keep+1:end)';
    opts.ProjectionMtx = opts.VMinimax'*opts.VMinimax;

%     opts.VMinimax = V(:,1:opts.params.NumSingularValues2Keep+1)';
%     opts.ProjectionMtx = opts.VMinimax'*opts.VMinimax;

%     invEig = diag(1./(diag(Eigens)+10));
%     invEig = diag(1./max(diag(Eigens),1));
%     opts.ProjectionMtx = V*invEig*V';

end