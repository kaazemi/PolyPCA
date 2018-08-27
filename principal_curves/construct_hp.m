function  [cost,edges]=construct_hp(temps,lambda)

s=temps;
s=[s s(:,2,:)]; 
s=[s s(:,1,:)];

p=zeros(size(s,3),size(s,3),2); % houdt paden bij
p(:,1,1)=[1:size(s,3)]';    p(:,2,1) = p(:,1,1);  %plaats initiele paden
p(:,1,2)=ones(1,size(s,3)); p(:,2,2) = 2*p(:,1,2);
pl=2*ones(size(s,3),1);

%build distance matrix
d=zeros(size(s,3),size(s,3),4);
cost = zeros(2*size(s,3)+1);
for s1=2:size(s,3)
  for s2=1:s1-1    % s2 is the smaller index
    % first compute eucl. distances between endpoints
    l = sqdist([s(:,1,s1) s(:,3,s1)],[s(:,1,s2) s(:,3,s2) ]);
    % next compute angles in radials between possible directions
    %a=zeros(2);
     a=hoek2(s(:,:,s1),s(:,:,s2));

    d(s1,s2,:)=reshape(l.*lambda*a,1,4); 
    
    d(s2,s1,:)=d(s1,s2,:);
    cost(2*(s1-1)+1:2*(s1-1)+2,2*(s2-1)+1:2*(s2-1)+2)=l+lambda*a;
    cost(2*(s2-1)+1:2*(s2-1)+2,2*(s1-1)+1:2*(s1-1)+2)=[l+lambda*a]';
  end
end



while size(s,3)>1 %merge segments

  mind=min(d,[],3);
  mind=mind+eye(size(mind,1))*10000;
  [a,s1]=min(mind); [a,s2]=min(a);s1=s1(s2); % get minimizing segments
  i=find(d(s1,s2,:)==a);                     % get the way they are combined
  i=i(1); %get first index if multiple exist

  if s1>s2              %make sure s1 is the smaller index
    a=s1;s1=s2;s2=a;end;%[s1,s2,i] 
  if i==1 
    a=1;b=1;
    p(s1,1:pl(s1),1)=fliplr(p(s1,1:pl(s1),1)); % flip old s1-path
    p(s1,1:pl(s1),2)=fliplr(p(s1,1:pl(s1),2));
    p(s1,1+pl(s1):pl(s1)+pl(s2),:)=p(s2,1:pl(s2),:);
  elseif i==2
    a=1;b=3;
    p(s1,1:pl(s1),1)=fliplr(p(s1,1:pl(s1),1)); % flip old s1-path
    p(s1,1:pl(s1),2)=fliplr(p(s1,1:pl(s1),2));
    p(s1,1+pl(s1):pl(s1)+pl(s2),1)=fliplr(p(s2,1:pl(s2),1));
    p(s1,1+pl(s1):pl(s1)+pl(s2),2)=fliplr(p(s2,1:pl(s2),2));
  elseif i==3
    a=3;b=1;
    p(s1,1+pl(s1):pl(s1)+pl(s2),:)=p(s2,1:pl(s2),:);
  else
    a=3;b=3;
    p(s1,1+pl(s1):pl(s1)+pl(s2),1)=fliplr(p(s2,1:pl(s2),1));
    p(s1,1+pl(s1):pl(s1)+pl(s2),2)=fliplr(p(s2,1:pl(s2),2));
  end
  p(s2,:,:)=[];pl(s1)=pl(s1)+pl(s2);pl(s2)=[];


  %create new segement
  if i<3 %first endpoint of s1 is used, keep the other
    s(:,1,s1)=s(:,3,s1);  s(:,2,s1)=s(:,4,s1);
  end
  if mod(i,2) % first endpoint of s2 is used, keep the other
    s(:,3,s1)=s(:,3,s2); s(:,4,s1)=s(:,4,s2);
  else % keep the first endpoint
    s(:,3,s1)=s(:,1,s2);  s(:,4,s1)=s(:,2,s2);
  end
  s(:,:,s2)=[]; % throw away old segment

  %update cost matrix

  d(s2,:,:)=[];
  d(:,s2,:)=[];
  t1=s1;
  for t2=1:size(s,3)
    if t2<t1           % make sure s2 is the smaller index 
      s1=t1;s2=t2;
    else
      s1=t2;s2=t1;
    end
    if s1~=s2
      l = sqdist([s(:,1,s1) s(:,3,s1)],[s(:,1,s2) s(:,3,s2)]); 
      a = [hoek(s(:,1,s1)-s(:,2,s1),s(:,2,s2)-s(:,1,s2)),hoek(s(:,1,s1)-s(:,2,s1),s(:,4,s2)-s(:,3,s2)); hoek(s(:,3,s1)-s(:,4,s1),s(:,2,s2)-s(:,1,s2)),hoek(s(:,3,s1)-s(:,4,s1),s(:,4,s2)-s(:,3,s2))];
      d(s1,s2,:)=reshape(l+lambda*a,1,4);
      d(s2,s1,:)=d(s1,s2,:);
    end
  end

end %path is constructed

%build edge matrix
kernel=1;kant=2;dummy=2*size(temps,3)+1;
edges=zeros(dummy);
edges(p(1,1,kant)+2*(p(1,1,kernel)-1),dummy)=1;
edges(dummy,p(1,1,kant)+2*(p(1,1,kernel)-1))=1;
edges(p(1,end,kant)+2*(p(1,end,kernel)-1),dummy)=1;
edges(dummy,p(1,end,kant)+2*(p(1,end,kernel)-1))=1;
for knoop=1:pl(1)-1
  edges(p(1,knoop,kant)+2*(p(1,knoop,kernel)-1),p(1,knoop+1,kant)+2*(p(1,knoop+1,kernel)-1))=1+mod(knoop,2);
  edges(p(1,knoop+1,kant)+2*(p(1,knoop+1,kernel)-1),p(1,knoop,kant)+2*(p(1,knoop,kernel)-1))=1+mod(knoop,2);
end





