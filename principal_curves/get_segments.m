function [segments,lengths]=get_segments(e,vertices)

d=size(vertices,1);

segments=zeros(d,2,size(e,1)-1);

segment=1; lengths=zeros(size(segments,3)+1,1);
i=find(sum(e)==2);i=i(1); %get an endpoint of path
j=find(e(i,:)>0);         % get neighbor

while segment <= size(segments,3)
  e(i,j)=0;e(j,i)=0;        % remove used edge
  segments(:,:,segment) = [vertices(:,i) vertices(:,j)];
  lengths(segment+1) = lengths(segment)+norm(vertices(:,i)-vertices(:,j));
  segment=segment+1;
  i=j;                      % find next segment
  j=find(e(i,:)>0);         % get neighbor
end % while

