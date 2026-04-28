function [kernel] = k_x(x,sigma,sigmas_index,i,j)
%dist = (x(i,:)-x(j,:))*(x(i,:)-x(j,:));
%global sigmas_index;
[~,col] = size(x);
dist = zeros(col);
for k = 1:col
    dist(k) = (x(i,k) - x(j,k))^2;
    %dist2(x(i,k),x(j,k));
end

kernel = 1;
for k = 1:col
    if sigmas_index(k) == 0
        break;
    end
    kernel = kernel * exp(dist(k)/(-2.0*sigma(sigmas_index(k))*sigma(sigmas_index(k))));
end

end

%function k = rbf(sigma)
    % Returns an RBF kernel function with the given bandwidth
%    constant = 1 / (2*(sigma^2));
%    k = @(x,y) exp(-constant*dist2(x, y));
%end
