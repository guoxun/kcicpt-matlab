function [ rate ] = testMyIchol(K,GGt,RankNum)
%TESTMYICHOL 此处显示有关此函数的摘要
%   此处显示详细说明
rate = norm(GGt-K,RankNum);
end

