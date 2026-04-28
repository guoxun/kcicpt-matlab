function mdist = median_pdist(X)
    % Returns median pairwise distance
    dists = pdist(X, 'euclidean');
    unique_dists = dists(find(triu(ones(size(dists)), 1)));
   mdist = median(unique_dists);
  %  mdist = 1;
  if mdist==0
       mdist = median(unique_dists(unique_dists>0));
  end
end
