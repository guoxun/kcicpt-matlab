function D = rkhs_distance_Z(Z, kernel)
    % Pairwise RKHS Distances
    [row,col] = size(Z);
    K = ones(row,row);
        for i = 1:col
        Kt = kernel{i}(Z(:,i),Z(:,i));
        K = K.*Kt;
        end
    O = ones(length(Z), 1);
    N = O*diag(K)';
    D = sqrt(N + N' - 2*K);  
end