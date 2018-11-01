function [dLx,dLA,opts] = dLiftingPenalty(A,x,Exponents,opts)
M = sum(Exponents(:,opts.TargetLatentDim+1:opts.params.d),2);
A(:,M == 0) = 0;
if opts.Lifting
    dLx = 0;
    dLA = 2*opts.LiftingRegularization*A;
    
%     X  = x2X(x,Exponents);
%     dx = dX2dx(x,Exponents);
%     dLA = opts.LiftingRegularization*A*(X*X');
%     dLA(:,M == 0) = 0;
%     dLx = 2*opts.LiftingRegularization*gradx(dx,A'*A*X);
%     opts.LiftingRegularization = opts.LiftingRegularization*opts.LiftingRegularizationRatio;
else
    dLx = 0;
    dLA = 0;
end

