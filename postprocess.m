function x = postprocess(x,opts)
   d = opts.d;
                                                    % and get rid of close local minima
%     x(1:d,:) = orth(randn(d))*x(1:d,:);           % do a random rotation
%     x = whiten(x,d);                                % whiten x
%     PolyPCA_messages('whiten',opts.iter)
%     x(1:d,1:d) = eye(d);
    x = x./max(abs(x),[],2);
    x(end,:) = 1;                                   % set the constant equal to 1 (avoids a separate gradient step)
%     if mod(opts.maxDeg,2) == 0
%         x = abs(x);
%     end
end

function x = whiten(x,d)
x = x-mean(x,2);
C = cov(x');
x(1:d,:) = sqrtm(C(1:d,1:d))\(x(1:d,:));
end