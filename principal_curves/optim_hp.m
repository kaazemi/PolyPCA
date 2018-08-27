function edges=optim_hp(e,c)
% do 2-opt tsp improvement
fprintf('improving path'); 

n=size(e,1); % n is number of cities
edges=e;
change=0;

a1=1;a2=2; % start with edges from first and second city

while ((a1<=n)|change)
 if a1>n 
  fprintf('@');
  change=0;  % no changes yet in new round
  a1=1;a2=2; %start all over again if end is reached
 end
 flipped =0;
 ok=0;
 while ~ok
  b1=find(edges(:,a1)==1); b1=b1(1);
  edges(a1,b1)=0;edges(b1,a1)=0; % delete edge from a1
  b2=find(edges(:,a2)==1); 
  if isempty(b2)           % no edges left from a2
  edges(a1,b1)=1;edges(b1,a1)=1;  % restore premature removal
   a2=a2+1;                % try next city for a2
   if a2>n                 % no cities left
    a2=1;
    a1=a1+1;
   end
  else
   b2=b2(1);
   edges(a2,b2)=0;edges(b2,a2)=0;ok=1;
  end
 end

 if ~hp_connected(edges,a1,a2) % make a1 is connected with a2 (and b1 with b2)
  temp=a2; a2=b2; b2=temp;
  flipped=1;
 end

 if (c(a1,b2)+c(a2,b1)) < (c(a1,b1)+c(a2,b2))
  fprintf('!');
change=1;
  edges(a1,b2)=1;edges(b2,a1)=1;edges(a2,b1)=1;edges(b1,a2)=1;
% continue for other segments and start over again if end is reached
 % a1=1;a2=2;  start checking for improvements again
 else
  % it didn't work, restore old stuff
%  'it did not work'
  edges(a1,b1)=1;edges(b1,a1)=1;edges(a2,b2)=1;edges(b2,a2)=1;
  if flipped
   temp=a2;a2=b2;b2=temp;
  end
  a2=a2+1; % try next citie(s)
  if a2>n
   a2=1;
   a1=a1+1;
  end
 end %if

end %while

fprintf('\n');

