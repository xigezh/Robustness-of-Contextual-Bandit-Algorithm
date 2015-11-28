function [ y ] = logistic_deriv( x )
%the derivative of logistic function

y=exp(x)./(1+exp(x))./(1+exp(x));


end

