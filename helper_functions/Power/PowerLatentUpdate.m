function [s,x,X,Sigmax,opts] = PowerLatentUpdate(x,Sigmax,SymA,y,Exponents,opts)
modes = 1:opts.params.maxDeg-1;
    s = filter(opts.theta,1,x,[],2);
    if opts.Flags.Dynamics
        R = 1;                      % observation noise
        for iter = 1:1
        AX  = cell(1,opts.params.T);
            x_k = x;
            S_k = Sigmax;
            for t = 1:opts.params.T
                AX{t}  = squeeze(tensorProduct(SymA,x(:,t),modes))';
                if t > 2
                    % Filtering
                    x_k(:,t) = -opts.theta(2)*x(:,t-1);
                    S_k(:,t) = opts.theta(2)^2*Sigmax(:,t-1)+opts.sigma2;
                    K = (S_k(:,t).*AX{t}')/(AX{t}*(S_k(:,t).*AX{t}')+R*eye(opts.params.n));
                    x(:,t) = x_k(:,t) + K*(y(:,t)-AX{t}*x_k(:,t));
                    Sigmax(:,t) = S_k(:,t) - diag(K*(AX{t}*(S_k(:,t).*AX{t}')+eye(opts.params.n))*K');
                end
            end
            for t = opts.params.T-1:-1:1
                    % Smoothing
                    S = -opts.theta(2)*Sigmax(:,t)./S_k(:,t+1);
                    x_k(:,t) = x(:,t) + S.*(x(:,t+1)-x_k(:,t+1));
                    Sigmax(:,t) = Sigmax(:,t) + S.^2.*(Sigmax(:,t+1)-S_k(:,t+1));
            end
        end
        s = filter(opts.theta,1,x,[],2);
    else
        for t = 1:opts.params.T
            AX  = squeeze(tensorProduct(SymA,x(:,t),modes))';
            s(:,t) = (AX'*AX)\AX'*y(:,t);            
        end
        x = s;
    end
    
    [x,opts] = postprocess(x,opts);
    X = x2X(x,Exponents);                                           % transform latents to monomials
end