function [m] = anal1(s)

x = unique(s(:,1));
% x = x(2:end);

for i=1:length(x)
    k = find(s(:,1) == x(i,1));
    x(i,2) = sum(s(k,2))/length(k);
end

% y = x(:,1);
% val1 = min(x(:,1));
% val2 = val1 + (0.1*val1);
% u = find((x(:,1)>= val1) & (x(:,1) < val2));
% v = find((s(:,1)>= val1) & (s(:,1) < val2));
% 
% while ~isempty(u)
%     y(u,2) = sum(x(u,2))/length(v);
%     temp = u(length(u));
%     u = [];
%     if temp+1 <= length(x(:,1))
%         val1 = x(temp+1,1);
%         val2 = val1 + (0.1*val1);
%         u = find((x(:,1)>= val1) & (x(:,1) < val2));
%         v = find((s(:,1)>= val1) & (s(:,1) < val2));
%     end
% end

figure;
plot(x(:,1), x(:,2)*100, 'ko-');
xlabel("Force stimulus [N]");
ylabel("Percent of true positives [%]");
title("Proportion of true positives depending on the force stimulus without pre-processing data");

b = s(s(:,1)~=0,1);
m = zeros(15,4);
for u=1:15
    m(u,1) = mode(b);
    b = b(b~=m(u,1));
end

m = sort(m);

v1 = m(1,1);
v2 = m(1,1)+((m(1+1,1)-m(1,1))/2);
u = find((s(:,1)>=v1) & (s(:,1) <=v2));
m(1,2) = sum(s(u,2));
m(1,3) = m(1,2) / length(u);
m(1,4) = length(u);
for z=2:14
   v1 = m(z,1)-((m(z,1)-m(z-1,1))/2);
   v2 = m(z,1)+((m(z+1,1)-m(z,1))/2);
   u = find((s(:,1)>v1) & (s(:,1) <=v2));
   m(z,2) = sum(s(u,2));
   m(z,3) = m(z,2) / length(u);
   m(z,4) = length(u);
end
v1 = m(15,1)-((m(15,1)-m(15-1,1))/2);
u = find((s(:,1)>v1));
m(15,2) = sum(s(u,2));
m(15,3) = m(15,2) / length(u);
m(15,4) = length(u);



end

