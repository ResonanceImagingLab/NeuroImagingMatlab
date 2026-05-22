close all
clear all
%Make the three gaussians
%1 - GM
y_1 = 0:0.001:0.8;
mu_1 = 0.307;
sigma_1 = 0.05;
f_1 = exp(-(y_1-mu_1).^2./(2*sigma_1^2)).*7000;
figure(1)
plot(y_1,f_1,':','Color','k','LineWidth',1.5)

%%
%2 - mGM
hold on
y_2 = 0:0.001:0.8;
mu_2 = 0.42;
sigma_2 = 0.06;
f_2 = exp(-(y_2-mu_2).^2./(2*sigma_2^2)).*2500;
plot(y_2,f_2,'LineWidth',1.5)

%%
%3 - WM
y_3 = 0:0.001:0.8;
mu_3 = 0.590;
sigma_3 = 0.035;
f_3 = exp(-(y_3-mu_3).^2./(2*sigma_3^2)).*6000;
plot(y_3,f_3,'LineWidth',1.5)

%%
%4 - sum of the gaussians
total_gaus = f_1 + f_2 + f_3;
plot(y_3,total_gaus,'LineWidth',2)