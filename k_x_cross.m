function [kernel] = k_x_cross(x,y,sigma,i,j)
dist = (x(i,:)-y(j,:))*(x(i,:)-y(j,:));
sigma1 = 2*sigma;
sigmal = prod(sigma1);
kernel = exp(dist/(-2*sigmal));
end
