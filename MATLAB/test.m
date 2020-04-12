x = linspace(.05,1,101);
p.t = .5;
bList = 1:4;
figure(1)
clf
subplot(1,2,1)
y = zeros(length(bList),length(x));
for i=1:length(bList)
    p.b = bList(i);
    y(i,:) = Weibull(p,x);
end
plot(log(x),y')
logx2raw;
legend(num2str(bList'),'Location','NorthWest');
xlabel('Intensity');
ylabel('Proportion Correct');
title('Varying b with t=0.3');
%
% Note how that the slopes vary, but all curves pass through the same
% point.  This is where x=p.t and y =a.  In our case, x=0.3 and y ~= .8.
%
% Next we'll plot a family of curves for a fixed slope(p.t) and varying
% threshold (p.t).

p.b = 2;
tList = [.1,.2,.4,.8];
subplot(1,2,2)
y = zeros(length(tList),length(x));
for i=1:length(tList)
    p.t = tList(i);
    y(i,:) = Weibull(p,x);
end
plot(log(x),y')

legend(num2str(tList'),'Location','NorthWest');
xlabel('Intensity');
ylabel('Proportion Correct');
set(gca,'XTick',log(tList));
logx2raw
title('Varying t with b=2');