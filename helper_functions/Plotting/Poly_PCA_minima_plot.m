function Poly_PCA_minima_plot(opts)
figure(101); 
step = .01;
limits = -.4:step:.4;
if opts.params.d == 2
[x1,x2] = meshgrid(limits);
else
    return;
end
X = x2X([x1(:)';x2(:)';ones(1,numel(x1))],opts.Exponents);

for t = 1:10:opts.params.T
    t
Z = opts.yOut(:,t)-opts.Aout*X;
f = reshape(sum(Z.^4).^.25,size(x1));
[DX,DY] = gradient(f,step,step);
subplot(1,2,1); cla; hold on;
contour(x1,x2,f,'LineWidth',3); 
quiver(x1,x2,DX,DY,'color','k','LineWidth',.7);
subplot(1,2,2);
surf(x1,x2,f)
drawnow;
end
end