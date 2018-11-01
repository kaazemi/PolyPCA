[gs,dLA,opts] = PolyPCAgrad(s,x,A,E,params.Exponents,opts);
[s,x,X,opts] = LatentUpdate(x,s,gs,params.Exponents,opts);
switch lower(opts.objective)
    case 'convex'
        A = eye(opts.params.ToKeep);
        %             [opts.Q,opts.Inv_QQt_Q] = SVP(X*y',opts.params.AdditiveFormulation.sigmaMin);%\(y*y') which is identity
        %             y = opts.Q*y;
        % No CoeffUpdate
        A0 = y*X'/(X*X');
        E0 = y-A0*X;
        [opts,E] = updatePolyPCAparams(y,E0,A,x,s,X,opts,gs,gA);
    otherwise
        [A,gA] = CoeffUpdate(y,A,dLA,X,opts);
        [opts,E] = updatePolyPCAparams(y,E,A,x,s,X,opts,gs,gA);
end