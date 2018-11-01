function dp = dpenalty(x,p)
[d,T] = size(x);
% dp = zeros(d,T);
switch p
    case 2
%         dp(1:d-1,:) = 2*x(1:d-1,:);
        dp = 2*x;
    case 1
%         dp(1:d-1,:) = sign(x(1:d-1,:));
        dp = sign(x);
    otherwise
%         dp(1:d-1,:) = p*x(1:d-1,:).^(p-1);
        dp = p*x.^(p-1);
end
end