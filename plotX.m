function opts = plotX(x,opts)
fontsize = 16;
figure(2);
if opts.iter == 2
   colormap(jet)
end
subplot(2,1,1);
% % plot(x(1:opts.d,:)','linewidth',4);
scatter(repmat(opts.params.colors,1,opts.d),vec(x(1:opts.d,:)'),[],repmat(opts.params.colors,1,opts.d));
if isfield(opts.params,'fs')
   opts.params.xtick = opts.params.xtick/fs;
end

title('Latents')
set(gca,'fontsize',fontsize);
if isfield(opts.params,'fs')
    xlabel('Time (Seconds)')
else
    xlabel('Time (Samples)')
end
subplot(2,1,2);
if opts.d == 2 || opts.d > 3
    scatter(x(1,:),x(2,:),[],opts.params.colors); 
    if opts.converged; colorbar
    end
else
    scatter3(x(1,:),x(2,:),x(3,:),[],opts.params.colors); colorbar
end
set(gca,'fontsize',fontsize);

title(['Iteration ' num2str(opts.iter) ' , nmse = ' num2str(opts.nmse_current) '%']);
drawnow;
cstr = ['Iteration ', num2str(opts.iter), ' Completed, '];
estr = ['error = ' num2str(opts.nmse_current) '%%'];
fprintf([repmat('\b',1,opts.pos),cstr,estr]); opts.pos = length(cstr)+length(estr)-1;
end