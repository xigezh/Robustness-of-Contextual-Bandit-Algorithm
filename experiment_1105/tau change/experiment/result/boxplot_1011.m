
csv_name1=strcat('online_exp_btsrp_burden_value_200_0.2_0.9_0.csv');
csv_name2=strcat('online_exp_btsrp_burden_value_200_0.2_0.9_0.2.csv');
csv_name3=strcat('online_exp_btsrp_burden_value_200_0.2_0.9_0.4.csv');
csv_name4=strcat('online_exp_btsrp_burden_value_200_0.2_0.9_0.6.csv');
rr1 = csvread(csv_name1);
rr2 = csvread(csv_name2);
rr3 = csvread(csv_name3);
rr4 = csvread(csv_name4);
rr = [rr1,rr2,rr3,rr4];
csv_name_optim_1=strcat('optimal_burden_0_0.2_0.9.csv');
csv_name_optim_2=strcat('optimal_burden_0.2_0.2_0.9.csv');
csv_name_optim_3=strcat('optimal_burden_0.4_0.2_0.9.csv');
csv_name_optim_4=strcat('optimal_burden_0.6_0.2_0.9.csv');

optim_reward_1 = csvread(csv_name_optim_1);
optim_reward_2 = csvread(csv_name_optim_2);
optim_reward_3 = csvread(csv_name_optim_3);
optim_reward_4 = csvread(csv_name_optim_4);

optim_reward = [optim_reward_1(2),optim_reward_2(2),optim_reward_3(2),optim_reward_4(2)];

tau = [repmat(0,1,length(rr(:,1))),repmat(0.2,1,length(rr(:,2))),repmat(0.4,1,length(rr(:,2))),repmat(0.6,1,length(rr(:,2)))];
boxplot(rr,tau);
hold on
plot(optim_reward,'r:');
legend('optimal');

title('Average reward verse tau');
xlabel('tau');
ylabel('Average reward');

