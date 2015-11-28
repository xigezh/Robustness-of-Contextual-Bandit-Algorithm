function [ y ] = logistic( x )
%logistic function

y=exp(x)./(1+exp(x));

end

