function [converged, nmse] = convergence(y,E,iter)
nmse = norm(E,'fro')/norm(y,'fro');
converged = nmse < 0.001 || iter == 1000; %||...
%norm(etaX*dx,'fro')/norm(Xold(1:end-1,:),'fro') < 0.001;
end
