function x = postprocess(x,iter)
    d = size(x,1)-1;
                                                    % and get rid of close local minima
%     x(1:d,:) = orth(randn(d))*x(1:d,:);           % do a random rotation
%     x = whiten(x,d);                                % whiten x
%     PolyPCA_messages('whiten',iter)
%     x(1:d,1:d) = eye(d);
    x = x./max(abs(x),[],2);
    x(end,:) = 1;                                   % set the constant equal to 1 (avoids a separate gradient step)
end

function x = whiten(x,d)
C = cov(x');
x(1:d,:) = sqrtm(C(1:d,1:d))\(x(1:d,:));
end