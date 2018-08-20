clear; clc; close all
options = odeset('MaxStep',0.1,'RelTol',1e-8,'AbsTol',1e-10);
% temp = inputdlg('Enter mu value');
% mu = str2double(temp{1,1});
mu = 3;
[t,x] = ode45(@(t,x) vdp1_1(t,x,mu),[0 8],[2; 0],options);
x1 = x(:,1);
a = 1.2;
x1(x1<-a) = -2*a-x1(x1<-a);
x(:,1) = x1;
% [t,x] = ode45(@(t,x) spiral(t,x),[0 5],[2; 0],options);
x = x';
figure(1),
subplot(2,2,1)
plot(x(1,:),x(2,:),'k','linewidth',3) , hold on
quiver(x(1,:), x(2,:), gradient(x(1,:)), gradient(x(2,:) ))
hold off
subplot(2,2,4); plot(x','linewidth',2)
x(end+1,:) = 1;
%%
k = 2; 
n = 100;
d = size(x,1)-1;
Exponents =  sortPoly(d,k);
ToKeep = nchoosek(d+k,d);
X = x2X(x,Exponents);
A_gt = randn(n,ToKeep);
A_mismatch = randn(n,d);
y = A_gt*X;
sigma = 0.1;
noise = sigma*randn(size(y));
mismatch = A_mismatch*(abs(x(1:d,:).^1.5)+log(1+abs(x(1:d,:))));
y_noisy = y + mismatch + noise;

subplot(2,2,2);
imagesc(y_noisy);
x_gt = x;

function dxdt = vdp1_1(t,y,mu)
dxdt = zeros(2,1);
if t < 5
    dxdt(1) = y(2);
    dxdt(2) = mu * (1-y(1)^2)*y(2)-y(1);
else
    dxdt(1) = y(2);
    dxdt(2) = -y(1);
end
end
function dxdt = spiral(t,y)
dxdt = zeros(2,1);
dxdt(1) = y(2)/(.01+t);
dxdt(2) = -y(1)/(.01+t);
end
function X = x2X(x,Exponents) %fixed
    [~,T] = size(x);
    ToKeep = size(Exponents,1);
    X = zeros(ToKeep,T);
    for t = 1:T
        X(:,t) = prod(x(:,t)'.^Exponents,2);
    end
end

