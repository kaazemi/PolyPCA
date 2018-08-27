% ans=seg_dist(v1, v2, x)
% compute the sq distance between x and the line segment from V1 to V2.
% d: sq distance
% p: projected point
% t: euclidean distance from projected point to v1 
function [d, t, p]=seg_dist(v1, v2, x)

a = 0;
b = norm(v2-v1);
u = (v2-v1)/norm(b); % unit vector % segment is line v1+tu with t in [0,b]

% get projection index on LINE (not segment!)

t = (x'-repmat(v1',size(x,2),1))*u; 

% get projection index on segment
t = max(t,a);
t = min(t,b);

p = repmat(v1',size(x,2),1) + t*u';  % get projected points
d=(x'-p);
d=d.*d;
d=sum(d,2);



