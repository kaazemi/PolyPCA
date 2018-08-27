function a=hoek2(X,Y)
% compute angle between segments X & S and S & Y
% where S is the segment connecting X and Y 
% both X and Y are 2x4 matrices with endpoints in columns

a=zeros(2);

%connect x1 and y1
a(1,1) = hoek(X(:,1)-X(:,2),Y(:,1)-X(:,1)) + hoek(Y(:,1)-X(:,1),Y(:,2)-Y(:,1));

%connect x1 and y3
a(1,2) = hoek(X(:,1)-X(:,2),Y(:,3)-X(:,1)) + hoek(Y(:,3)-X(:,1),Y(:,4)-Y(:,3));

%connect x3 and y1
a(2,1) = hoek(X(:,3)-X(:,4),Y(:,1)-X(:,3)) + hoek(Y(:,1)-X(:,3),Y(:,2)-Y(:,1));

%connect x3 nd y3
a(2,2) = hoek(X(:,3)-X(:,4),Y(:,3)-X(:,3)) + hoek(Y(:,3)-X(:,3),Y(:,4)-Y(:,3));



