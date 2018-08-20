function dp = dpenalty(x,penalty,p)
[d,T] = size(x);
dp = zeros(d,T);
switch penalty
    case 'l2'
        
        dp(1:d-1,:) = 2*x(1:d-1,:);
    case 'l1'
        dp(1:d-1,:) = sign(x(1:d-1,:));
    case 'lp'
        dp(1:d-1,:) = p*x(1:d-1,:).^(p-1);
    otherwise
        error('invalid penalty type');
end
end