function [A,s,x,X] = InitializePolyPCA(type,y,n,ToKeep,d,T,theta,x0,Exponents)
switch type
    case 'random'
        %% Initialization Type I : Random spikes
        A = randn(n,ToKeep);
        s = randn(d+1,T);
        x = filter(1,theta,s,[],2);
        x = x./sum(x,2);
        x(end,:) = 1;
        X = x2X(x,Exponents);
    case 'EMPCA'
        %% Initialization Type II: Embedding+PCA
        x = x0;
        x = x./sum(x,2);
        x(end,:) = 1;
        s = filter(theta,1,x,[],2);
        X = x2X(x,Exponents);
        A = y*X'/(X*X')+randn(n,ToKeep);
end

end

