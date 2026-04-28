function ci_test = kcipt_pc(dataset, alpha)
    function accept = test(x, y, S)
        S = unique(S);
        X = dataset(:,x);
        Y = dataset(:,y);
        global sigmas_index;
        sigmas_index(1)=x;
        sigmas_index(2)=y;
        for i = 1:length(S)
            sigmas_index(i+2)=S(i);
        end        
        if length(S) == 0
            Z = zeros(size(X));
            k_Z = rbf(1.0);
            k_Zs ={};
            k_Zs{1} = rbf(1.0);
            options.distance = 'random';
            boptions.bootstrap_samples = 10;
        else
       %     Z1 = dataset(:,S);
        %    Len = size(X);
     %       [~,Z] = kmeans(Z1,Len(1,1));
      %      k_Z = rbf(median_pdist(Z));
            Z = dataset(:,S);
            [row,col] = size(Z);
            k_Z = rbf(median_pdist(Z));
            k_Zs ={};
            for i = 1:col
            k_Zs{i} = rbf(median_pdist(Z(:,i)));   
            end
            options.distance = 'rkhs';
            boptions.bootstrap_samples = 10;
        end
        k_X = rbf(median_pdist(X));
        k_Y = rbf(median_pdist(Y));
        new_test = bootstrap(@kcipt, boptions);
        options.null_estimate = 'bootstrap';
        options.bootstrap_samples = 10000;
        [statistic null] = new_test(X, Y, Z, k_X, k_Y, k_Z, k_Zs, options);
        pvalue = null.pvalue(statistic)
        accept = (pvalue > alpha);
        for i = 1:length(sigmas_index)
            sigmas_index(i)=0;
        end 
    end
    ci_test = @test;
end
