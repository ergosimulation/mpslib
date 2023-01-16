function [ind]=sample_from_1d(P);

cP=cumsum(P);
r=rand(1);
ind=min(find(r<cP));
