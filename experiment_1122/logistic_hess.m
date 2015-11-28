function [ y ] = logistic_hess( x )
%the hessian of logistic function

y=exp(x).*(1-exp(x))./(1+exp(x)).^3;


end

