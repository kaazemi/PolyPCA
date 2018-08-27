function con=hp_connected(edges,i,j)
% returns 1 if i,j are connected in the graph defined by edges

if i==j
 con=1; 
 return;
end

while 1
 next=find(edges(:,i)>0);
 edges(next,i)=0;edges(i,next)=0;
 i=next;
 if isempty(i)
  con=0;
  return;
 end
 if i==j
  con=1;
  return;
 end
end
