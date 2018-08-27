function con=hp_connected(edges,i,j)
% returns 1 if i,j are endpoints of the same path
%i
%j

if i==j
 con=1; 
 return;
end

while 1
 next=find(edges(:,i)>0);
 if isempty(next)
  con=0;
  return;
 end
 next=next(1);
 edges(next,i)=0;edges(i,next)=0;
 i=next;
 if i==j
  con=1;
  return;
 end
end
