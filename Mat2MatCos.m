function [cos]=Mat2MatCos(A,B)
T = A - B;
T = T.*T;
T = abs(T);
cos = sum(sum(T));
end