function pos = plotX(x,d,c,iter,nmse_current,pos)
figure(2);
subplot(2,1,1);
plot(x(1:d,:)','linewidth',3);
subplot(2,1,2);
if d == 2 || d > 3
scatter(x(1,:),x(2,:),[],c);
else
scatter3(x(1,:),x(2,:),x(3,:),[],c);
end
title(['Iteration ' num2str(iter) ' ,Constant = ' num2str(x(end,1)) ]);
drawnow;
cstr = ['Iteration ', num2str(iter), ' Completed, '];
estr = ['error = ' num2str(nmse_current) '%%'];
fprintf([repmat('\b',1,pos),cstr,estr]); pos = length(cstr)+length(estr)-1;
end