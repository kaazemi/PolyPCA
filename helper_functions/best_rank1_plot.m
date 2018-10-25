%%
% clear; clc; close all
d = 2;
k = 5;
ToKeep = nchoosek(d+k,k);
r = 100;
singularVecs = randn(d,r); 
T = zeros(d*ones(1,k));
for i = 1:r
    dummy = singularVecs(:,i);
    for j = 1:k-1
        dummy = kron(dummy,singularVecs(:,i));
    end
    dummy = reshape(dummy,size(T));
    T = T + dummy;    
end
T = 10*T/r;

EmbeddingDim = d;
[x,e] = best_sym_rank1(T,EmbeddingDim)

num = 50;
lims = [-30,30];


if d == 3
    x1 = linspace(lims(1),lims(2),num);
    f = nan(num,num,num);
    for i = 1:num
        for j = 1:num
            for l = 1:num
                x = [x1(i);x1(j);x1(l)];
                dummy = x;
                for m = 1:k-1
                    dummy = kron(dummy,x);
                end
                dummy = reshape(dummy,size(T));
                f(i,j,l) = norm(dummy(:)-T(:));
            end
        end
    end
    [x1,x2,x3] = meshgrid(x1);
elseif d == 2
    x1 = linspace(lims(1),lims(2),num);
    f = nan(num);
        for i = 1:num
            for j = 1:num
                    x = [x1(i);x1(j)];
                    dummy = x;
                    for m = 1:k-1
                        dummy = kron(dummy,x);
                    end
                    dummy = reshape(dummy,size(T));
                    f(i,j) = norm(dummy(:)-T(:));
            end
        end
            [x1,x2] = meshgrid(x1);
end

if d == 2
    subplot(2,2,1); colormap(hsv)
    surf(x1,x2,f); 
    subplot(2,2,2); colormap(hsv)
    contour(x1,x2,f); colorbar;
    set(gca,'fontsize',20);
    subplot(2,2,3);
    contour(x1,x2,x1.^(2*k)+x2.^(2*k));
elseif d == 3
    imshow3D(f);
end

minf = min(f(:))
