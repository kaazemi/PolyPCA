function [y,d]=map_to_arcl(e,vertices,x)

%map all datapoints to latent variable which is obtained by mapping point
% to closest point on path 
% path is indexed continuously in [0,l(P)] where l(P) is the length of the path

[n,d]=size(x);
[segments, lengths]=get_segments(e,vertices);

y=zeros(n,d+1); % labels in arc length (1dim) + projected points (d-dim)

dists = zeros(n,size(segments,3));
rest  = zeros(n,d+1,size(segments,3));
for i=1:size(segments,3)
  [d t p]=seg_dist(segments(:,1,i),segments(:,2,i),x'); 
  dists(:,i)=d;
  rest(:,:,i)=[t p];
end
[d,vr]=min(dists,[],2);
for i=1:n
  y(i,:) = rest(i,:,vr(i));
  y(i,1)=y(i,1)+lengths(vr(i));
end




