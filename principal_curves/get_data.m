function T=get_data(NumPoints,RS,type)

d=2;T=zeros(NumPoints,d);Tr=zeros(NumPoints,d);

if type=='sin_3'
a=10;
  for i=1:NumPoints
    Tr(i,:) = [a*(i/NumPoints) sin(a*pi*i/NumPoints)];
  end
end

if type=='l_spi'
  for i=1:NumPoints
    Tr(i,:) = [(6*log(i/NumPoints))*sin(.1+2*pi*i/NumPoints) (6*log(i/NumPoints))*cos(.1+2*pi*i/NumPoints)];
  end

end


if type=='sp_5p'
  for i=1:NumPoints
    Tr(i,:) = [((i/NumPoints)+.002)*sin(4.5*pi*i/NumPoints) ((i/NumPoints)+.002)*cos(4.5*pi*i/(NumPoints))];
  end
end

if type=='sp_3p'
  for i=1:NumPoints
    Tr(i,:) = [(2*(i/NumPoints)+.2)*sin(3*pi*i/NumPoints) (2*(i/NumPoints)+.2)*cos(3*pi*i/(NumPoints))];
  end
end

if type=='sp_3d'
  d=3;T=zeros(NumPoints,d);Tr=zeros(NumPoints,d);
  for i=1:NumPoints
    Tr(i,:) = [(2*(i/NumPoints))*sin(5*pi*i/NumPoints) (2*(i/NumPoints))*cos(5*pi*i/(NumPoints)) 4*sqrt(i/NumPoints)];
  end
end

if type=='cros1' 
  for i=1:NumPoints
    Tr(i,:)=[sin(pi*i/NumPoints) i/NumPoints+cos(3*pi*i/NumPoints)];
  end
end


if  type=='cros2'
  for i=1:NumPoints
    Tr(i,:)=[(sqrt(i)/sqrt(NumPoints)+.1)*sin(4*pi*sqrt(i)/sqrt(NumPoints)) (i/NumPoints+.1)+cos(3*pi*sqrt(i)/sqrt(NumPoints))];
  end
end

if type=='cros3'
  for i=1:NumPoints
    Tr(i,:)=[(sqrt(i)/sqrt(NumPoints))*(.1+sin(.4+4*pi*(i)/(NumPoints))) (i/NumPoints+.1)+(1+cos(.1+3*pi*(i)/(NumPoints)))];
  end
end

if type=='circl'
fprintf('generating circle data\n');
  for i=1:NumPoints
    Tr(i,:) = [sin(2*pi*i/NumPoints) cos(2*pi*i/NumPoints)];
  end
end

if type=='cir_h'
  for i=1:NumPoints
    Tr(i,:) = [sin(pi*i/NumPoints) cos(pi*i/NumPoints)];
  end
end

fprintf('adding noise to data\n');
for i=1:NumPoints
 T(i,:)=Tr(i,:)+RS*randn(1,d);
end


if type=='joris'
  load('Jorisdata.mat');T=X;
end

if type=='robo1'
  T=load('pl.dat');T=sph_dat(T);
end

if type=='robo2'
  T=load('pl_2.dat');T=T-repmat(mean(T),size(T,1),1);
  for i=1:size(T,2)
    T(:,i)=T(:,i)/max(abs(T(:,i)));
  end
end

if (type=='joris' | type=='robo1'| type=='robo2')
T=[rand(size(T,1),1) T];T=sortrows(T);T=T(:,2:end);T=T(1:NumPoints,:);
end
