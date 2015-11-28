function [ y ] = logistic_tri( x )
%the third derivative of logistic function

y=(exp(x)-4*exp(2*x)+exp(3*x))./(1+exp(x)).^4;


end

