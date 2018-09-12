function PolyPCA_ObjectivePlot(k,opts)
% close all;
% a = randsample(10000,1) %591
a = 560;
rng(591,'twister'); %591
if nargin < 2
    opts = [];
end
if ~isfield(opts,'lims')
        lims = [-3,3];
else
    lims = opts.lims;
end

d = 3;

x_star = [randn(d,1);1];
Exponents = sortPoly(d,k);
% n = size(Exponents,1);
n = 50;
X_star = x2X(x_star,Exponents);
A_star = randn(n,size(Exponents,1));
A = randn(n,size(Exponents,1));
A_ = A;
% A_(:,[1,k+1,end]) = 2*A(:,[1,k+1,end]);
% a = randsample(1000,1); %591
rng(a,'twister'); %309
% y = A_star*X_star + randn(n,1);
y = 5+10*randn(n,1);

%% 
m = 0;
if m>0
    A = [A;randn(m,size(Exponents,1))];
    y = [y;5+10*randn(m,1)];
end
if m<0
    A(end+m:end,:) = [];
    y(end+m:end) = [];
end


%%



num = 200;
l = linspace(lims(1),lims(2),num);
[x1, x2] = meshgrid(l);
z = zeros(num);
for i = 1:num
    for j = 1:num
        if d == 3
            X = x2X([l(i);l(j);0;1],Exponents);%1.0408
            z(i,j) = sum(abs(y-A*X).^2);
%             for k = num:-1:1
%                 X = x2X([l(i);l(j);l(k);1],Exponents);
%                 z(i,j,k) = sum(abs(y-A*X).^2);
%             end
        else
            X = x2X([l(i);l(j);1],Exponents);
            z(i,j) = sum(abs(y-A*X).^2);
        end
    end
end
% for i = 1:num
%     [pks{i}, locs{i}] = findpeaks(-z(i,:));
% end
% for i = 1:num
%     [pks{i+num}, locs{i+num}] = findpeaks(-z(:,j));
% end
    
    m = prctile(z(:),15);
    indices = z < m;
    [m1] = min(x1(indices));
    [M1] = max(x1(indices));
    m2 = min(x2(indices));
    M2 = max(x2(indices));
    z(x1>M1) = nan; z(x1<m1) = nan;
    z(x2>M2) = nan; z(x2<m2) = nan;
    x1(isnan(z)) = nan;
    x2(isnan(z)) = nan;
    row = find(nansum(abs(x1),2)>0,1,'first');
    col = find(nansum(abs(x2))>0,1,'first');
    i1 = find(~isnan(x1(row,:)),1,'first');
    I1 = find(~isnan(x1(row,:)),1,'last');
    i2 = find(~isnan(x2(:,col)),1,'first');
    I2 = find(~isnan(x2(:,col)),1,'last');
    x1 = x1(i1-1:I1,i2-1:I2);
    x2 = x2(i1-1:I1,i2-1:I2);
    z = z(i1-1:I1,i2-1:I2); z = z/1e4;
    subplot(2,2,1); colormap(hsv)
    surf(x1,x2,z); 
    subplot(2,2,2); colormap(hsv)
    contour(x1,x2,z); colorbar;
    set(gca,'fontsize',20);
    subplot(2,2,3);
    contour(x1,x2,x1.^(2*k)+x2.^(2*k));
    
    minz = min(z(:))
end

