clc
clear all
close all

s1 = zeros(20,2,4);
s2 = zeros(20,2,4);

s1(:,:,1) = load('../11.txt');
s2(:,:,1) = load('../12.txt');
s1(:,:,2) = load('../21.txt');
s2(:,:,2) = load('../22.txt');
s1(:,:,3) = load('../31.txt');
s2(:,:,3) = load('../32.txt');
s1(:,:,4) = load('../41.txt');
s2(:,:,4) = load('../42.txt');
s1(:,:,5) = load('../51.txt');
s2(:,:,5) = load('../52.txt');
s1(:,:,6) = load('../61.txt');
s2(:,:,6) = load('../62.txt');
s1(:,:,7) = load('../71.txt');
s2(:,:,7) = load('../72.txt');

S1 = [s1(:,:,1); s1(:,:,2); s1(:,:,3); s1(:,:,4); s1(:,:,5); s1(:,:,6); s1(:,:,7)];
S2=  [s2(:,:,1); s2(:,:,2); s2(:,:,3); s2(:,:,4); s2(:,:,5); s2(:,:,6); s2(:,:,7)];

S1 = S1(S1(:,1)~=0,:);
S2 = S2(S2(:,1)~=0,:);

m1 = anal1(S1);
m2 = anal2(S2);


% figure;
% stairs(1:20, s1(:,1,1));
% hold on
% plot(find(s1(:,2,1) == 0), s1(s1(:,2,1) == 0,1,1), 'ko','MarkerFaceColor','r');
% plot(find(s1(:,2,1) == 1), s1(s1(:,2,1) == 1,1,1), 'ko','MarkerFaceColor','g');
% xlabel("Trial");
% ylabel("Force stimulus [N]");
% title("Plot illustrating the variation of the force stimulus across trials");

% figure;
% plot(m1(:,1), m1(:,3)*100,  'ko-','MarkerFaceColor','b','MarkerSize',8);
% xlabel("Force stimulus [N]");
% ylabel("Percent of true positives [%]");
% 
% figure;
% plot(m2(:,1), m2(:,3)*100, 'ko-','MarkerFaceColor','b','MarkerSize',8);
% xlabel("Force stimulus [N]");
% ylabel("Percent of true positives [%]");


bestL1 = -99999;
bestT1 = 0;
bestB1 = 0;
for t=20:150
    for b=5:15
        pGuess.t =t/1000;
        pGuess.b = b;
        x1 = linspace(min(m1(:,1)),max(m1(:,1)),15)';
        y1 = Weibull(pGuess,x1, max(m1(:,3)));
        y1 = y1*.99+.005;
        likelihood = sum(m1(:,2).*log(y1) + (m1(:,4)-m1(:,2)).*log(1-y1));
        display(likelihood);
        if likelihood > bestL1
           bestL1 = likelihood;
           bestT1 = t;
           bestB1 = b;
        end
    end
end

bestL2 = -99999;
bestT2 = 0;
bestB2 = 0;
for t=20:150
    for b=2:15
        pGuess.t =t/1000;
        pGuess.b = b;
        x2 = linspace(min(m2(:,1)),max(m2(:,1)),10)';
        y2 = Weibull(pGuess,x2, max(m2(:,3)));
        y2 = y2*.99+.005;
        likelihood = sum(m2(:,2).*log(y2) + (m2(:,4)-m2(:,2)).*log(1-y2));
        display(likelihood);
        if likelihood > bestL2
           bestL2 = likelihood;
           bestT2 = t;
           bestB2 = b;
        end
    end
end

pGuess.t = bestT1/1000;
pGuess.b = bestB1;
x1 = linspace(min(m1(:,1)),max(m1(:,1)),15)';
y1 = Weibull(pGuess,x1, max(m1(:,3)));
figure;
plot(m1(:,1),m1(:,3),'ko-','MarkerFaceColor','b');
hold on;
plot(x1,y1,'r-','linewidth',2);
xlabel("Force stimulus [N]");
ylabel("proportion of true positives");

pGuess.t = bestT2/1000;
pGuess.b = bestB2;
x2 = linspace(min(m2(:,1)),max(m2(:,1)),10)';
y2 = Weibull(pGuess,x2, max(m2(:,3)));
figure;
plot(m2(:,1),m2(:,3),'ko-','MarkerFaceColor','b');
hold on;
plot(x2,y2,'r-','linewidth',2);
xlabel("Force stimulus [N]");
ylabel("Proportion of true positives");

%------------------------------------------------------------------------

