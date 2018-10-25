function opts = plotX(x,opts)
fontsize = 16;
figure(2);
if opts.iter == 2
   colormap(jet)
end
subplot(2,1,1);
cla;
% % plot(x(1:opts.d,:)','linewidth',4);

scatter(repmat(opts.params.colors,1,opts.TargetLatentDim),vec(x(1:opts.TargetLatentDim,:)'),[],repmat(opts.params.colors,1,opts.TargetLatentDim));
hold on;
plot(x(opts.TargetLatentDim+1:opts.d,:)',':k')
if isfield(opts.params,'fs')
   opts.params.xtick = opts.params.xtick/fs;
end
if opts.converged; colorbar; end
title('Latents')
set(gca,'fontsize',fontsize);
if isfield(opts.params,'fs')
    xlabel('Time (Seconds)')
else
    xlabel('Time (Samples)')
end
if opts.Lifting
    switch opts.LiftingMethod
        case {'Projection','projection','project'}
            x = opts.SubspaceCoeffs*x(1:opts.d,:);
        case {'penalty','Penalty'}
            x = x(1:opts.TargetLatentDim,:);
        otherwise 
            error
    end
    
end
subplot(2,1,2);
if opts.TargetLatentDim == 3 %|| opts.d == 3
    scatter3(x(1,:),x(2,:),x(3,:),[],opts.params.colors);
else
    scatter(x(1,:),x(2,:),[],opts.params.colors);  
end
if opts.converged; colorbar; end
set(gca,'fontsize',fontsize);

title(['Iteration ' num2str(opts.iter) ' , nmse = ' num2str(opts.nmse_current) '%, explained variance = ' num2str(opts.explained_var) '%']);
drawnow;
cstr = ['Iteration ', num2str(opts.iter), ' Completed, '];
estr = ['error = ' num2str(opts.nmse_current) ' %%' ', explained variance = ' num2str(opts.explained_var) ' %%'];
% estr = ['error = ' num2str(opts.nmse_current) '%%'];
fprintf([repmat('\b',1,opts.pos),cstr,estr]); opts.pos = length(cstr)+length(estr)-2;
if opts.converged
    fprintf('\n')
end
end