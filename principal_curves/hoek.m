function h=hoek(v1,v2)
% compute angle between COLUMN vectors X and Y


v1=v1/norm(v1);
v2=v2/norm(v2);

prod = v1'*v2;

h=acos(prod)/pi;

