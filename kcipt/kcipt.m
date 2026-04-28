function [statistic null] = kcipt(X, Y, Z, k_X, k_Y, k_Z, k_Zs, options)
    % Performs the KCIPT with the given distance metric and null estimation
    global sigmas;
    global sigmas_index;
    global debugNum;
    % Parse Options
    if nargin < 7
        options.distance = 'regression';
        options.null_estimate = 'gamma';
        options.bootstrap_samples = 1000;
        options.kernel = 'supplied';
        options.split = 1;
    else
        if ~isfield(options, 'distance')
            options.distance = 'regression';
        end
        if ~isfield(options, 'null_estimate')
            options.distance = 'gamma';
        end
        if ~isfield(options, 'bootstrap_samples')
            options.bootstrap_samples = 1000;
        end
        if ~isfield(options, 'kernel')
            options.kernel = 'supplied';
        end
        if ~isfield(options, 'split')
            options.split = 1;
        end
    end
    n = length(X);
    halfn = floor(n/2);

    % Split dataset in half?
    if options.split
        X1 = X(1:halfn,:);
        X2 = X(halfn+1:2*halfn,:);
        Y1 = Y(1:halfn,:);
        Y2 = Y(halfn+1:2*halfn,:);
        Z1 = Z(1:halfn,:);
        Z2 = Z(halfn+1:2*halfn,:);
    else
        X1 = X; X2 = X;
        Y1 = Y; Y2 = Y;
        Z1 = Z; Z2 = Z;
    end

    % Compute distance
    if strcmp(options.distance, 'rkhs')
        ClusterNum =200;
        s = rng;
        [idx,~] = kmeans(Z1,ClusterNum);
        rng(s);
     %   rand('twister',mod(floor(now*8640000),2^31-1));
     %   idx = ones(length(Z1),1);
        D = {};
        Pindex={};
        for i = 1:ClusterNum 
            if i==79
              i=79;  
            end
            if ~isempty(find(idx==i))
        D{i} = rkhs_distance_Z(Z1(idx==i), k_Zs);
        Pindex{i} = find(idx==i);
            else
        Pindex{i} = [];
            end
        end 
    %    D = rkhs_distance_Z(Z1, k_Zs);
    elseif strcmp(options.distance, 'random')
        D = [];
    else
        error(sprintf('Unknown distance metric "%s"',...
                      options.distance));
    end

    % Compute permutation
    if isempty(D)
        P = eye(halfn);
        [notUsed, indperm] = sort(rand(halfn, 1));
        P = P(indperm, :);
        [Zindex,~] = find(P==1);
    else
%          P = linear_permutation(D);
%         [Zindex,~] = find(P==1);
       Zindex = zeros(halfn,1);
       Zindex_1 = zeros(halfn,1);
       Zindex_1_num =1;
       for i = 1:ClusterNum
        if isempty(Pindex{i})
            continue;
        end
       if length(D{i})==1
        P=1;  
        Zindex_1(Zindex_1_num) =Pindex{i};
        Zindex_1_num = Zindex_1_num + 1;
       elseif sum(sum(D{i})) == 0
        P = eye(length(D{i}));
        [notUsed, indperm] = sort(rand(length(D{i}), 1));
        P = P(indperm, :);
       else
      if debugNum == 11295
            debugNum = 11295;
      end
        P= linear_permutation(D{i});   
        debugNum = debugNum +1
       end           
       [mi,~] = find(P==1);
       Zindex(Pindex{i}) = Pindex{i}(mi);
       end 
      [notUsed, indperm] = sort(rand(Zindex_1_num-1, 1));
      Z_Index_Cluster_1=Zindex_1(find(Zindex_1~=0));
      Zindex(Z_Index_Cluster_1) = Z_Index_Cluster_1(indperm);
    end
    % P matrix to vector
     %  Y4 = Y1;
     %  Y1 = P'*Y1;
    Y1 = Y1(Zindex);
    % Compute statistic
    if strcmp(options.kernel, 'supplied')
   %     K = k_X(X1, X1).*k_Y(Y1, Y1).*k_Z(Z1, Z1);
   %     L = k_X(X2, X2).*k_Y(Y2, Y2).*k_Z(Z2, Z2);
   %     KL = k_X(X1, X2).*k_Y(Y1, Y2).*k_Z(Z1, Z2);
        
        X_Big = X(1:2*halfn,:);
        Y_Big = [Y1;Y2];
        Z_Big = Z(1:2*halfn,:);
 %      GGk = k_X(X_Big,X_Big).*k_Y(Y_Big,Y_Big).*k_Z(Z_Big,Z_Big);
        OMG = [X_Big,Y_Big,Z_Big];
        max_M = 10;
        N = length(X_Big);
        kappa = 0.02;
        c_fraction = 0.001;
        epsilon= c_fraction*0.5*N*kappa;
      %function [G,M] = MyIchol(x,N,epsilon,max_M)
        G_Big = MyIchol(OMG,N,epsilon,sigmas,sigmas_index,max_M);
  %      GGt =  G_Big*G_Big';
   %     testEpsilon = norm(GGk - G_Big*G_Big',2);
   %     disp('epsilon'+testEpsilon);
        L1 = sum(G_Big(1:halfn,:));
        L2 = sum(G_Big(halfn+1:2*halfn,:));      
    else
        error(sprintf('Unknown kernel "%s"',...
                      options.kernel));
    end
    
    statistic = (sum(L1.*L1) + sum(L2.*L2) - 2*sum(L1.*L2))/halfn; 
   
    
 %  statistic = (dot(L1,L1)+dot(L2,L2)-2*dot(L1,L2))/halfn;
  
%    statistic1 = sum(sum(K + L - KL - KL')) / halfn;
%    deviation = statistic1 - statistic;
if strcmp(options.null_estimate, 'bootstrap')
      GaussNum = 100;
      Gauss_mmds = zeros(GaussNum,1);
   %     KK = [K KL; KL' L];
       for b_Gauss = 1:GaussNum
            [notUsed, indperm] = sort(rand(2*halfn,1));
            L1_Rand = sum(G_Big(indperm(1:halfn),:));
            L2_Rand = sum(G_Big(indperm(halfn+1:2*halfn),:)); 
    %        mmds(b) = (dot(L1_Rand,L1_Rand)+dot(L2_Rand,L2_Rand)-2*dot(L1_Rand,L2_Rand))/halfn;
            Gauss_mmds(b_Gauss) = (sum(L1_Rand.*L1_Rand) + sum(L2_Rand.*L2_Rand) - 2*sum(L1_Rand.*L2_Rand))/halfn;    
       end
       Gauss_Mean = mean(Gauss_mmds);
       Gauss_Std = std(Gauss_mmds);
       mmds = zeros(options.bootstrap_samples, 1);
       for b=1:options.bootstrap_samples
       mmds(b) = normrnd(Gauss_Mean,Gauss_Std);
       end
%        mmds = zeros(options.bootstrap_samples, 1);
%         for b=1:options.bootstrap_samples
%             [notUsed, indperm] = sort(rand(2*halfn,1));
%             L1_Rand = sum(G_Big(indperm(1:halfn),:));
%             L2_Rand = sum(G_Big(indperm(halfn+1:2*halfn),:)); 
%     %        mmds(b) = (dot(L1_Rand,L1_Rand)+dot(L2_Rand,L2_Rand)-2*dot(L1_Rand,L2_Rand))/halfn;
%             mmds(b) = (sum(L1_Rand.*L1_Rand) + sum(L2_Rand.*L2_Rand) - 2*sum(L1_Rand.*L2_Rand))/halfn; 
%   %          KKperm = KK(indperm,indperm);
%    %         K = KKperm(1:halfn,1:halfn);
%    %         L = KKperm(halfn+1:2*halfn,halfn+1:2*halfn);
%    %         KL = KKperm(1:halfn,halfn+1:2*halfn);
%    %         mmds(b) = sum(sum(K + L - KL - KL')) / halfn;
%         end
        null = EmpiricalNull(mmds);%inner

    else
        error(sprintf('Unknown null estimation technique "%s"',...
                      options.null_estimate));
end

end
