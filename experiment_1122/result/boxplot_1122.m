
csv_name1=strcat('value_x_coeff_is1_tau_is0.2.csv');
csv_name2=strcat('value_x_coeff_is1_tau_is0.4.csv');
csv_name3=strcat('value_x_coeff_is1_tau_is0.6.csv');

tau_0_2 = csvread(csv_name1);
tau_0_4 = csvread(csv_name2);
tau_0_6 = csvread(csv_name3);

csv_name_optim_1=strcat('optimal_burden_0_0.2_0.9x_coeff1.csv');
csv_name_optim_2=strcat('optimal_burden_0.2_0.2_0.9x_coeff1.csv');
csv_name_optim_3=strcat('optimal_burden_0.4_0.2_0.9x_coeff1.csv');

optim_reward_1 = csvread(csv_name_optim_1);
optim_reward_2 = csvread(csv_name_optim_2);
optim_reward_3 = csvread(csv_name_optim_3);



%optim_reward = [optim_reward_1(2),optim_reward_2(2),optim_reward_3(2),optim_reward_4(2),optim_reward_5(2),optim_reward_6(2)];

max_time_data = [repmat(200,1,length(tau_0_2(:,1))),repmat(400,1,length(tau_0_2(:,2))),repmat(600,1,length(tau_0_2(:,3))),repmat(800,1,length(tau_0_2(:,4))),repmat(1000,1,length(tau_0_2(:,5)))];

figure(1)
subplot(3,1,1);
boxplot(tau_0_2,max_time_data);
hold on
hline = refline([0 optim_reward_1(2)]);
legend('optimal');
title('Average reward verse max_time when tau is 0.2');
xlabel('max_time');
ylabel('Average reward');

subplot(3,1,2);
boxplot(tau_0_4,max_time_data);
hold on
hline = refline([0 optim_reward_2(2)]);
legend('optimal');
title('Average reward verse max_time when tau is 0.4');
xlabel('max_time');
ylabel('Average reward');


subplot(3,1,3);
boxplot(tau_0_6,max_time_data);
hold on
hline = refline([0 optim_reward_3(2)]);
legend('optimal');
title('Average reward verse max_time when tau is 0.6');
xlabel('max_time');
ylabel('Average reward');


fig = figure(1);
saveas(fig,'ave reward vs max_time.jpg');
