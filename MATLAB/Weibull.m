function y = Weibull(p,x,mx)
%y = Weibull(p,x)
%
%Parameters:  p.b slope
%             p.t threshold yeilding ~80% correct
%             x   intensity values.

g = 0.5;  %chance performance
e = (.5)^(1/2);  %threshold performance ( ~70%)

%here it is.
k = (-log( (1-e)/(1-g)))^(1/p.b);
y = mx- (1-g)*exp(- (k*x/p.t).^p.b);