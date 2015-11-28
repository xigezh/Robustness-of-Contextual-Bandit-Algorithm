
csv_name1=strcat('value_x_coeff_is0.csv');
csv_name2=strcat('value_x_coeff_is0.6.csv');
csv_name3=strcat('value_x_coeff_is1.csv');

x_0 = csvread(csv_name1);
x_0_6 = csvread(csv_name2);
x_1 = csvread(csv_name3);

csv_name_optim_1=strcat('optimal_burden_0_0.2_0.9x_coeff0.csv');
csv_name_optim_2=strcat('optimal_burden_0_0.2_0.9x_coeff0.6.csv');
csv_name_optim_3=strcat('optimal_burden_0_0.2_0.9x_coeff1.csv');

optim_reward_1 = csvread(csv_name_optim_1);
optim_reward_2 = csvread(csv_name_optim_2);
optim_reward_3 = csvread(csv_name_optim_3);



%optim_reward = [optim_reward_1(2),optim_reward_2(2),optim_reward_3(2),optim_reward_4(2),optim_reward_5(2),optim_reward_6(2)];

max_time_data = [repmat(200,1,length(x_0(:,1))),repmat(400,1,length(x_0(:,2))),repmat(600,1,length(x_0(:,3))),repmat(800,1,length(x_0(:,4))),repmat(1000,1,length(x_0(:,5)))];

figure(1)
subplot(3,1,1);
boxplot(x_0,max_time_data);
hold on
hline = refline([0 optim_reward_1(2)]);
legend('optimal');
title('Average reward verse max_time when x_co is 0');
xlabel('max_time');
ylabel('Average reward');

subplot(3,1,2);
boxplot(x_0_6,max_time_data);
hold on
hline = refline([0 optim_reward_2(2)]);
legend('optimal');
title('Average reward verse max_time when x_co is 0.6');
xlabel('max_time');
ylabel('Average reward');

subplot(3,1,3);
boxplot(x_1,max_time_data);
hold on
hline = refline([0 optim_reward_3(2)]);
legend('optimal');
title('Average reward verse max_time when x_co is 1');
xlabel('max_time');
ylabel('Average reward');

axis([max_time Average reward],[0 1000 9.5 9.9]);

fig = figure(1);
saveas(fig,'ave reward vs max_time.jpg');
