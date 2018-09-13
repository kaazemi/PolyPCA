function x = postprocess(x,opts)
% and get rid of close local minima
%     x(1:opts.d,:) = orth(randn(opts.d))*x(1:opts.d,:);           % do a random rotation
      x = x - mean(x,2);
%     x = whiten(x,opts.d);                                % whiten x
%     PolyPCA_messages('whiten',opts.iter)
%     x(1:d,1:d) = eye(d);
%     x = x-min(x,[],2);
%     x(1:opts.d,:) = (x(1:opts.d,1:opts.d))\x(1:opts.d,:);

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