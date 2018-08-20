function yEmbedded = embed(y,EmbeddingDim,delay)
% Delay embeds the observation matrix y, where time is the second index
[p,T] = size(y);
y0 = [zeros(p,delay*(EmbeddingDim-1)),y];
yEmbedded = zeros(EmbeddingDim*p,T);
for t = 1:T
    yEmbedded(:,t) = vec(y0(:,t:delay:t+delay*(EmbeddingDim-1))');
end

end