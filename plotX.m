function opts = plotX(x,opts)
figure(2);
subplot(2,1,1);
plot(x(1:opts.d,:)','linewidth',3);
subplot(2,1,2);
if opts.d == 2 || opts.d > 3
    scatter(x(1,:),x(2,:),[],opts.c);
else
    scatter3(x(1,:),x(2,:),x(3,:),[],opts.c);
end
title(['Iteration ' num2str(opts.iter) ' ,Constant = ' num2str(x(end,1)) ]);
drawnow;
cstr = ['Iteration ', num2str(opts.iter), ' Completed, '];
estr = ['error = ' num2str(opts.nmse_current) '%%'];
fprintf([repmat('\b',1,opts.pos),cstr,estr]); opts.pos = length(cstr)+length(estr)-1;
end