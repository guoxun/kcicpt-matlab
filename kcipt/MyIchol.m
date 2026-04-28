function [G1] = MyIchol(x,N,epsilon,sigmas,sigmas_index,max_M)
i = 1;
j = 1;
k = 1;
tp = 0;
temp = 0;
temp1 =0;
diag_G = zeros(N,1);
G = zeros(N,max_M);
sum =0;
P = 1:N;
for i = 1:N
    diag_G(i) = k_x(x,sigmas,sigmas_index,i,i);
end

for i = 1:N
    sum = sum + diag_G(i);
end

for i = 1:max_M
    G(i,i) = diag_G(i);
end

i =1;
index = 1;
while (sum > epsilon) && (i<= max_M)
%while (sum > epsilon) 
    % find the largest diag entry
    temp = diag_G(i);
    index = i;
    for j = i:N
        if diag_G(j) > temp
            temp = diag_G(j);
            index = j;
        end
    end
    %Updating P
    tp = P(index);
    P(index) = P(i);
    P(i) = tp;
    
    %Updating G
    for k = 1:i
        if k>=i
            break;
        end
        temp = G(index,k);
        G(index,k) = G(i,k);
        G(i,k) = temp;
    end  


    temp = diag_G(index);
    diag_G(index) = diag_G(i);
    diag_G(i) = temp;
    
    %Updating i¡¢i of G
    if diag_G(i)>0
        G(i,i) = sqrt(diag_G(i));
    else
        break;
    end
     %Calculate the i-th col
     for k = i+1:N
      temp =  k_x(x,sigmas,sigmas_index,P(k),P(i));
      temp1 =0;
      j=1;
      if j<i
      for j = 1:i-1
          temp1 = G(k,j)*G(i,j) + temp1;
      end    
      end
     G(k,i) = 1.0/G(i,i)*(temp - temp1);
     end
     %Updating diag_G
     for k = i+1:N
       temp =  k_x(x,sigmas,sigmas_index,P(k),P(k)); 
       temp1 = 0;
       j = 1;
       if j<=i
       for j = 1:i
       temp1 = G(k,j)*G(k,j) + temp1;  
       end
       end

       diag_G(k) = temp - temp1;
     end
     sum =0;
     for k = i+1:N
         sum = sum + diag_G(k);
     end    
     i= i+1;    
end
M = i;
%re order G
[~,index_P] = sort(P);
G1 = G(index_P,:);
end

