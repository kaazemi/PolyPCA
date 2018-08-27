function plot_pad(edges,vertices)

Ws=1;Cs='k';
Wi=1;Ci='r';


for i=2:size(edges,1)  %skip first, if connected  will come later!
  j=find(edges(:,i)==2);
  if ~isempty(j)
    if size(vertices,1)==2
      line([vertices(1,i);vertices(1,j)],[vertices(2,i);vertices(2,j)],'LineWidth',Ws,'Color',Cs);
    elseif size(vertices,1)==3
      line([vertices(1,i);vertices(1,j)],[vertices(2,i);vertices(2,j)],[vertices(3,i);vertices(3,j)],'LineWidth',Ws,'Color',Cs);
    end
  end
  j=find(edges(:,i)==1);
  if ~isempty(j)
    if size(vertices,1)==2
      line([vertices(1,i);vertices(1,j)],[vertices(2,i);vertices(2,j)],'LineWidth',Wi,'Color',Ci);
    elseif size(vertices,1)==3
      line([vertices(1,i);vertices(1,j)],[vertices(2,i);vertices(2,j)],[vertices(3,i);vertices(3,j)],'LineWidth',Wi,'Color',Ci);
    end
  end
end

drawnow;
